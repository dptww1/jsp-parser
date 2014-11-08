require 'parslet'
require 'parslet/convenience'

class JspParser < Parslet::Parser
  def ds(start_delimiter, end_delimiter=start_delimiter)
    str(start_delimiter) >> (str(end_delimiter).absent? >> any).repeat >> str(end_delimiter)
  end

  rule(:s) { match('\\s').repeat }

  rule(:quoted_string) { ds("'") | ds('"') }

  rule(:id) { match('[A-Za-z_]') >> match('[A-Za-z0-9_]').repeat }

  rule(:parameters) { (parameter >> s).repeat }
  rule(:parameter) { id.as(:name) >> s >> str('=') >> s >> quoted_string.as(:value) }

  rule(:tag) { str('<%') >> (str('%>').absent? >> any).repeat.as(:content) >> str('%>') }

  rule(:action) { str('<') >> id.as(:namespace) >> str(':') >> id.as(:action_type) >> s >> parameters >> str('/>') }

  rule(:other) { (str('<%').absent? >> str('<jsp:').absent? >> any) }

  rule(:jsp_file) { (tag | action | other >> s).repeat }

  root :jsp_file
end
