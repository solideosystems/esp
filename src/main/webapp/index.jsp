<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=utf-8" %>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>ESP</title>
    <link rel="stylesheet" href="./css/core.css">
    <link rel="stylesheet" href="./css/intro.css">
    <link rel="stylesheet" href="./css/theme.blue.css">
</head>
<body>
<div class="esp-header">
    <div class="esp-header__title">국회 업무관리 시스템</div>
    <div class="esp-header__timer">01:59:59</div>
    <div class="esp-header__iam" title="내 정보 수정">
        <a href="/iam" class="esp-header__iam--name">
            <span class="material-icons">assignment_ind</span>
            <span id="account">최강욱</span>
        </a>
    </div>
    <button class="esp-header__logout" title="로그아웃">
        <span class="material-icons">power_settings_new</span>
    </button>
</div>

<div class="esp-container">
    <nav class="esp-fnb" aria-label="fnb">
        <div class="esp-fnb--item esp-fnb--active" title="전체메뉴"><span
                class="material-icons">menu</span></div>
        <div class="esp-fnb--item" title="즐겨찾기"><span class="material-icons">bookmarks</span></div>
        <div class="esp-fnb--item" title="공지사항"><span class="material-icons">notifications</span>
        </div>
        <div class="esp-fnb--item" title="Q&A"><span class="material-icons">live_help</span></div>
    </nav>

    <nav class="esp-gnb" aria-label="gnb">
        <div class="esp-gnb__menu"></div>
    </nav>

    <main class="esp-main">
        <div class="esp-main--header">
            <div class="esp-main__title">메뉴관리</div>
            <ul class="esp-main__paths">
                <li>시스템관리</li>
                <li>메뉴및권한</li>
                <li>메뉴관리</li>
            </ul>
            <button class="esp-main__bookmark">
                <span class="material-icons">bookmark_add</span>
            </button>
        </div>

        <div class="esp-app">
            <iframe src="" name="app" width="100%" height="100%" title="app"></iframe>
        </div>
    </main>
</div>

<script src="<c:url value="/js/jquery-3.6.0.min.js"/>"></script>
<script src="<c:url value="/js/jquery.support.js"/>"></script>
<script defer>
  function _branches(item, _ul) {
    var _at = document.createElement('a')
    _at.setAttribute('target', 'app')
    _at.appendChild(document.createTextNode(item.name))
    var _li = document.createElement('li')
    _li.appendChild(_at)
    _ul.appendChild(_li)

    item.uri && $(_at)
    .attr('href', item.uri)
    .attr('id', item.id)
    .data('menu', item)

    var filteredChildren = item.children.filter(function (i) {
      return !i.removal
    })

    if (filteredChildren.length) {
      var ul = document.createElement('ul')
      _li.appendChild(ul)
      filteredChildren.forEach(function (i) {
        _branches(i, ul)
      })
    }

    return _li
  }

  // menu
  $.ajax({
    async: false,
    url: '/_menu?id=0'
  })
  .done(function (items) {
    top.env.menu = items

    var root = $('.esp-gnb__menu'),
        ul = document.createElement('ul')

    root.append(ul)

    items.children.filter(function (i) {
      return !i.removal
    }).forEach(function (i) {
      _branches(i, ul)
    })

    var flatMenu = [items].reduce(function re(a, b) {
      var res = a.concat(b.children)
      if (b.children && b.children.length) {
        res = b.children.reduce(re, res)
      }

      return res
    }, [])

    var active = 'esp-gnb__menu--active'

    root.find('a').click(function () {

      var _this = $(this)
      var _li = _this.parent('li')

      _li.parent('ul')
      .find('> .' + active).removeClass(active)
      .find('> ul').stop().slideUp('100')

      _this.next().length
      && _this.next().stop().slideDown(300)

      do {
        _li.addClass(active)
      } while ((_li = _li.parent().parent('li')).length)

      // set active menu
      var paths = $('.esp-main__paths')
      var item = _this.data('menu')
      if (item) {
        item.uri && $('iframe[name=app]').prop('src', item.uri)

        $('.esp-main__title').text(item.name)

        paths.children().remove()

        do {
          paths.prepend('<li>' + item.name + '</li>')

          item = flatMenu.filter(function (i) {
            return i.id === item.pid
          })[0]
        } while (item)
      }
    })

    // initial selected
    var el = root.find('#-5').click()
    while ((el = el.parent().parent('ul')).show().length) {/* empty */
    }
  })

  $('.esp-fnb--item[title=전체메뉴]').click(function () {
    $('.esp-gnb').animate({'margin-left': top.env.active.gnb ? -250 : 0}, 100)
    top.env.active.gnb = !top.env.active.gnb
  })

  // timer
  $(function () {
    var time = 60 * 60 * 2

    function ticktock() {
      time--

      var hours = Math.floor(time / 3600),
          minutes = Math.floor(time % 3600 / 60),
          seconds = time % 60

      $('.esp-header__timer').text(
          [('0' + hours).substr(-2),
            ('0' + minutes).substr(-2),
            ('0' + seconds).substr(-2)]
          .join(':').replace(/^(00:)+/, '')
      )

      setTimeout(ticktock, 1000)
    }

    ticktock()
  })
;
</script>
</body>
</html>
