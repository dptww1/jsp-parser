require 'helper'

# need parens around hash literals, else assert_xxx treats them as blocks
# and gets a syntax error.

class TestJspParser < Minitest::Test

  def test_parses_include_directive
    elts = JspParser.new.parse "<%@ include file='here is the filename'%>"
    assert_equal 1, elts.size
    refute_nil elts[0][:element]
  end

  def test_parses_jsp_include
    elts = JspParser.new.parse "<jsp:include file='foo.jsp'/>"

    assert_equal 1, elts.size
    assert_equal ({ :namespace => "jsp",
                    :action_type => "include",
                    :parameters => [:name => "file", :value => "foo.jsp"] }), elts[0][:element]
  end

  def test_parses_jsp_includes
    elts = JspParser.new.parse <<-TEST_PARSES_JSP_INCLUDES
        <jsp:include file='foo.jsp'/>
        <jsp:include file="bar.jsp"/>
    TEST_PARSES_JSP_INCLUDES

    assert_equal 2, elts.size
    assert_equal ({ :namespace => "jsp",
                    :action_type => "include",
                    :parameters => [:name => "file", :value => "foo.jsp"] }), elts[0][:element]
    assert_equal ({ :namespace => "jsp",
                    :action_type => "include",
                    :parameters => [:name => "file", :value => "bar.jsp"] }), elts[1][:element]
  end

  def test_parses_comments
    elts = JspParser.new.parse <<-TEST_PARSES_JSP_COMMENTS
        <%--
          <jsp:include file='foo.jsp'/> --%>
        <%--
           <jsp:include file="bar.jsp"/>
          --%>"
    TEST_PARSES_JSP_COMMENTS

    assert_equal 2, elts.size
    refute_nil elts[0][:comment]
    refute_nil elts[1][:comment]
  end

  def test_parses_custom_namespace
    elts = JspParser.new.parse <<-TEST_PARSES_JSP_COMMENTS
          Random text <cms:render value="${foo}"/> end text
    TEST_PARSES_JSP_COMMENTS

    assert_equal 1, elts.size
    assert_equal 1, elts[0].size
    assert_equal ({ :namespace => "cms",
                    :action_type => "render",
                    :parameters => [{ :name => "value", :value => "${foo}" }] }), elts[0][:element]
  end

  def test_parses_nested_actions
    elts = JspParser.new.parse_with_debug <<-TEST_PARSES_NESTED_ACTIONS
      <cms:render value="${foo}">
          <jsp:param name="bar" value="baz"/>
      </cms:render>
    TEST_PARSES_NESTED_ACTIONS

    assert_equal ({ :namespace => "cms",
                    :action_type => "render",
                    :parameters => [{ :name => "value", :value => "${foo}" }],
                    :content => [{
                      :element => {
                        :namespace => "jsp",
                        :action_type => "param",
                        :parameters => [{ :name => "name", :value => "bar" }, { :name => "value", :value => "baz" }]
                      }}] }), elts[0][:element]
  end

#  def test_parses_complex_file
#    str = File.read("#{File.dirname(__FILE__)}/files/layout.jsp") { |f| f.read }
#    elts = JspParser.new.parse_with_debug(str)
#    refute_nil elts
#    refute_empty elts
#  end
end
