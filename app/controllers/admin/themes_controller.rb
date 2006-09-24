class Admin::ThemesController < Admin::BaseController
  @@theme_export_path = RAILS_PATH + 'tmp/export'
  cattr_accessor :theme_export_path
  
  before_filter :find_theme, :only => [:preview_for, :export, :change_to]

  def preview_for
    send_file((@theme.preview.exist? ? @theme.preview : RAILS_PATH + 'public/images/mephisto/preview.png').to_s, :type => 'image/png', :disposition => 'inline')
  end

  def export
    theme_site_path = temp_theme_path_for(params[:id])
    theme_zip_path  = theme_site_path   + "#{params[:id]}.zip"
    theme_zip_path.unlink if theme_zip_path.exist?
    @theme.export_as_zip params[:id], :to => theme_site_path
    theme_zip_path.exist? ? send_file(theme_zip_path.to_s, :stream => false) : raise("Error sending #{theme_zip_path.to_s} file")
  ensure
    theme_site_path.rmtree
  end
  
  def change_to
    site.change_theme_to @theme
    flash[:notice] = "Your theme has now been changed to '#{params[:id]}'"
    redirect_to :controller => 'design', :action => 'index'
  end

  def import
    return unless request.post?
    unless params[:theme] && params[:theme].size > 0 && params[:theme].content_type.strip == 'application/zip'
      flash.now[:error] = "Invalid theme upload."
      return
    end
    filename = params[:theme].original_filename
    filename.gsub!(/(^.*(\\|\/))|(\.zip$)/, '')
    filename.gsub!(/[^\w\.\-]/, '_')
    begin
      theme_site_path = temp_theme_path_for(filename)
      zip_file        = theme_site_path + "temp.zip"
      File.open(zip_file, 'wb') { |f| f << params[:theme].read }
      site.import_theme zip_file, filename
      flash[:notice] = "The '#{filename}' theme has been imported."
      redirect_to :action => 'index'
    ensure
      theme_site_path.rmtree
    end
  end

  protected
    def find_theme
      show_404 unless @theme = site.themes[params[:id]]
    end

    def temp_theme_path_for(prefix)
      returning theme_export_path + "site-#{site.id}/#{prefix}#{Time.now.utc.to_i.to_s.split('').sort_by { rand }}" do |path|
        FileUtils.mkdir_p path unless path.exist?
      end
    end

    alias authorized? admin?
end
