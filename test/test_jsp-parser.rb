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
    assert_equal ({ :namespace => "jsp", :action_type => "include" }), elts[0][:element][0]
    assert_equal ({ :name => "file", :value => "foo.jsp" }), elts[0][:element][1]
  end

  def test_parses_jsp_includes
    elts = JspParser.new.parse <<-TEST_PARSES_JSP_INCLUDES
        <jsp:include file='foo.jsp'/>
        <jsp:include file="bar.jsp"/>
    TEST_PARSES_JSP_INCLUDES

    assert_equal 2, elts.size
    assert_equal ({ :namespace => "jsp", :action_type => "include" }), elts[0][:element][0]
    assert_equal ({ :name => "file", :value => "foo.jsp" }), elts[0][:element][1]
    assert_equal ({ :namespace => "jsp", :action_type => "include" }), elts[1][:element][0]
    assert_equal ({ :name => "file", :value => "bar.jsp" }), elts[1][:element][1]
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
    assert_equal ({ :namespace => "cms", :action_type => "render" }), elts[0][:element][0]
    assert_equal ({ :name => "value", :value => "${foo}" }), elts[0][:element][1]
  end
end
