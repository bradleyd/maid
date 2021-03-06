require 'logger'
require 'ohai'
require 'rbconfig'
require 'stringio'
require 'xdg'

# > What is Dependency Testing?
# >
# > Examines an application's requirements for pre-existing software, initial states and configuration in order to
# > maintain proper functionality.
# >
# > -- http://sqa.fyicenter.com/FAQ/Software-QA-Testing/What_is_Dependency_Testing_.html
describe 'Dependency expectations' do
  describe Logger do
    # Depending on the situation, `Logger` might have been overwritten to have a different interface.  (I'm looking at you, Rails.)
    it 'logs with the expected interface' do
      io = StringIO.new
      logger = Logger.new(io)
      logger.info('my message')
      logger.formatter = lambda { |_, _, _, msg| msg }
      io.string.should match(/my message/)
    end
  end

  describe Ohai do
    before do
      @ohai = Ohai::System.new
      # FIXME: For some reason this is really slow when using `guard`
      @ohai.require_plugin('os')
    end
  
    it 'has platform information' do
      @ohai.require_plugin('platform')
      @ohai['platform'].should match(/[a-z]+/i)
      @ohai['platform_version'].should match(/[0-9]+/)
    end
  
    it 'has Ruby information' do
      ruby = @ohai['languages']['ruby']
      ruby['version'].should match(/^[0-9\.]+$/i)
      ruby['platform'].should match(/[a-z0-9]+/i)
    end
  end

  describe RbConfig do
    it 'identifies the host operating system' do
      RbConfig::CONFIG['host_os'].should match(/[a-z]+/)
    end
  end

  describe XDG do
    it 'has DATA_HOME' do
      # FIXME: This test could be cleaner.  We can't depend on the directory to already exist, even on systems that use
      # the XDG standard.  This seems safe enough for now.
      #
      # More info:
      #
      # * [XDG Base Directory Specification](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)
      XDG['DATA_HOME'].to_s.should match(%r{^/.*?/\.local/share$})
    end
  end
end
