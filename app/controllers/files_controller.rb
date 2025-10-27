class FilesController < ApplicationController
  STORAGE_DIR = Rails.root.join('storage', 'uploads')

  before_action :ensure_storage_dir!

  def index
    @files = Dir.children(STORAGE_DIR).sort.map do |name|
      path = STORAGE_DIR.join(name)
      {
        name: name,
        size: path.size,
        mtime: path.mtime
      }
    end
  end

  def download
    filename = params[:filename].to_s
    safe_name = File.basename(filename) # avoid path traversal
    file = STORAGE_DIR.join(safe_name)
    head :not_found and return unless file.file?

    # send_file with streaming enabled for large files
    send_file file,
              disposition: 'attachment',
              filename: safe_name,
              stream: true,
              buffer_size: 64.kilobytes
  end

  def create
    uploaded = params[:file]
    redirect_to files_path, alert: 'No file selected' and return unless uploaded.respond_to?(:original_filename)

    safe_name = File.basename(uploaded.original_filename)
    dest = STORAGE_DIR.join(safe_name)

    # Write efficiently from temp file to destination (doesn't load into memory)
    File.open(dest, 'wb') do |f|
      IO.copy_stream(uploaded.tempfile, f)
    end

    redirect_to files_path, notice: "Uploaded #{safe_name}"
  end

  private

  def ensure_storage_dir!
    FileUtils.mkdir_p(STORAGE_DIR) unless STORAGE_DIR.exist?
  end
end
