<%@include file="/WEB-INF/jsp/common/tagLibs.jsp" %>

<jsp:include page="/WEB-INF/jsp/common/newStartPage.jsp"/>

<cms:layout class="package-grid feature">

    <cms:render area="header">
        <!-- INLINE STYLES -->
        <style>
            ${mainContent.inlineStyles}
        </style>
        <jsp:include page="/WEB-INF/jsp/common/blogheader.jsp"/>
    </cms:render>

    <cms:render area="main-nav" class="nav-col breadcrumbs-area">
        <nav id="main-nav" class="clearfix-alt">
            <div class="container">
                <jsp:include page="/WEB-INF/jsp/common/blogNav.jsp">
                    <jsp:param name="activationEnabled" value="true"/>
                </jsp:include>
            </div>
        </nav>

    </cms:render>

    <cms:render area="banner">
        <div class="package-banner banner-tall">
            <div class="banner-wrapper package-header">
                <c:if test="${mainContent.useBackground}">
                    <div class="package-title">
                        <h1>${mainContent.plainTitle}</h1>
                        <h2>${mainContent.subtitle}</h2>
                    </div>
                </c:if>
                <c:if test="${!empty mainContent.promoBlock}">
                    <div class="package-promo pull-right bg-gold">
                        <div id="text">
                            <span class="title">${mainContent.promoBlock.title}</span>
                            <span class="subtitle">${mainContent.promoBlock.subtitle}</span>
                            <cms:a href="${mainContent.promoBlock.link.href}">${mainContent.promoBlock.linkText}</cms:a>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </cms:render>

    <!-- content -->
    <cms:render area="main-content" class="article-page package">
        <cms:render value="${mainContent}"/>
    </cms:render>

    <!-- /footer -->
    <cms:render area="footer" class="footer">
        <!-- social bar -->
        <div class="socialfooter">
            <div class="container">
                <jsp:include page="/WEB-INF/jsp/common/social.jsp"/>
            </div>
        </div>
        <!-- social bar -->

        <!-- second menu -->
        <div class="footerNav">
            <nav class="clearfix-alt">
                <div class="container">
                    <jsp:include page="/WEB-INF/jsp/common/blogNav.jsp">
                        <jsp:param name="activationEnabled" value="false"/>
                    </jsp:include>
                </div>
            </nav>
        </div>
        <!-- /second menu -->

        <div class="footer">
            <jsp:include page="/WEB-INF/jsp/common/blogfooter.jsp"/>
        </div>
    </cms:render>
    <!-- /footer -->
</cms:layout>
<jsp:include page="/WEB-INF/jsp/common/blogEndPage.jsp"/>
