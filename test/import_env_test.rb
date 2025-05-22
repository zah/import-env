require 'minitest/autorun'
require 'open3'
require 'tempfile'

SHELLS = %w[sh bash zsh dash ksh fish]
IGNORED = /^(export _=|export LOGNAME=|export OLDPWD=|export A__z=|export SHLVL=|export USER=)/

def run_script(shell, body, env = {})
  interpreter = `which #{shell}`.strip
  file = Tempfile.new('script')
  file.write("#!#{interpreter}\n#{body}\n")
  file.close
  File.chmod(0755, file.path)
  output, status = Open3.capture2(env, 'ruby', 'bin/import-env', file.path)
  file.unlink
  [output, status.exitstatus]
end

class ImportEnvTest < Minitest::Test
  def filtered(output)
    output.lines.reject { |l| l =~ IGNORED }
  end

  SHELLS.each do |sh|
    define_method("test_no_changes_#{sh}") do
      out, code = run_script(sh, '')
      assert_equal 0, code
      assert_empty filtered(out), out
    end

    define_method("test_added_#{sh}") do
      out, code = run_script(sh, 'export NEWVAR=hello')
      assert_equal 0, code
      assert_includes out.lines, "export NEWVAR='hello'\n"
    end

    define_method("test_modified_#{sh}") do
      env = { 'TESTVAR' => 'orig' }
      out, code = run_script(sh, 'export TESTVAR=$TESTVAR:/extra', env)
      assert_equal 0, code
      assert_includes out.lines, "export TESTVAR='orig:/extra'\n"
    end

    define_method("test_deleted_#{sh}") do
      env = { 'DELVAR' => 'gone' }
      cmd = sh == 'fish' ? 'set -e DELVAR' : 'unset DELVAR'
      out, code = run_script(sh, cmd, env)
      assert_equal 0, code
      assert_includes out.lines, "unset DELVAR\n"
    end
  end
end
