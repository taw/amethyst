task :default => :package

desc "Build Amethyst package"
task :package do
    date_string = Time.new.gmtime.strftime("%Y-%m-%d-%H-%M")
    files = FileList['Rakefile', 'amethyst.pl', 'README', 'Amethyst/*.pm', '*.am'].map{|f| "amethyst/#{f}"}
    Dir.chdir("..") {
        sh "tar", "-z", "-c", "-f", "../website/packages/amethyst-#{date_string}.tar.gz", *files
        #sh "zip", "-q", "-9", "../website/packages/amethyst-#{date_string}.zip", *files
    }
end

desc "Clean generated files"
task :clean do
    # Nothing to clean
end

desc "Run all tests (none at the moment, sorry)"
task :test do
    # No automatic test implemented yet
end
