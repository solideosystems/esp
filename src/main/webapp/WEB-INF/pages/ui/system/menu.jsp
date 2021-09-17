<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:grid title="메뉴관리">
    <main>
        <section class="app--column">
            <div>
                <div class="app-button btn-group float-right">
                    <button id="하위메뉴_추가_버튼" class="btn btn-default" disabled></button>
                    <button id="메뉴구조_저장_버튼" class="btn btn-default"></button>
                </div>
                <h4>메뉴 구조</h4>

                <ul id="메뉴"></ul>
            </div>
            <div>
                <div class="app-button float-right">
                    <button id="권한저장_버튼" class="btn btn-default">저장</button>
                </div>

                <h4>메뉴에 접근 가능한 권한</h4>

                <ul id="권한" class="authority namu"></ul>
            </div>
        </section>

        <figure id="메뉴입력_팝업" class="app--popup" title="메뉴 정보 입력">
            <form action="/_menu">
                <label title="상위메뉴">
                    <input name="pid" data-view="parentName" readonly>
                </label>
                <label title="유형">
                    <select name="type">
                        <option value="">일반페이지</option>
                        <option value="00">게시판</option>
                        <option value="01">링크</option>
                    </select>
                </label>
                <label title="이름">
                    <input name="name" required>
                </label>
                <label title="URL">
                    <ins class="fn__bbs">/board/</ins>
                    <input name="uri" pattern="[\w-]*"
                           aria-label="게시판 유형은 알파벳과 숫자, _ 또는 -만 쓸 수 있어요.">
                </label>
                <label title="팝업기능" class="fn__popup">
                    <input name="props.open.blank" type="checkbox"> 새창으로 띄우기
                </label>
                <label title="설명">
                    <textarea name="description"></textarea>
                </label>
                <label title="오픈일시">
                    <input type="datetime-local" name="opened">
                </label>
                <label title="삭제여부">
                    <input type="checkbox" name="removal">
                </label>

                <div class="app-button">
                    <button class="btn btn-default">저장</button>
                </div>
            </form>
        </figure>
    </main>

    <script src="${pageContext.request.contextPath}/js/namu.min.js"></script>
    <script defer>
      var selected = null,
          authorities = [],
          ordered = {},
          ul = $('#메뉴')

      $.req.get('/_authority?id=0')
      .done(function (response) {
        authorities = response
        _roleBranches(authorities, $('#권한'))
      })

      $.req.get('/_menu?id=0')
      .done(function (response) {
        _branches(response, ul)
        namu(ul[0]).drop(_menuDropEvent)
      })
    </script>
    <script defer title="이벤트">
      $('#메뉴').click('li', function (e) {
        e.stopPropagation()
        selected && selected.removeClass('menu--selected')

        selected = $(e.target).closest('li').addClass('menu--selected')
        selected.menu = selected.data('menu')
        selected.authorized = []

        $('#하위메뉴_추가_버튼').removeAttr('disabled')
      })
      .dblclick('li', function () {
        $('#메뉴입력_팝업').modal({
          onOpen: function () {
            selected.menu.parentName = (selected.parent().parent('li').data('menu') || {}).name
            $('#메뉴입력_팝업 > form').setJson(selected.menu)
          }
        })
      })

      $('#하위메뉴_추가_버튼').click(function () {
        $('#메뉴입력_팝업').modal({
          onOpen: function () {
            $('#메뉴입력_팝업 > form').setJson({
              pid: selected.menu.id,
              parentName: selected.menu.name,
              isNew: true
            })
          }
        })
      })

      $('#메뉴입력_팝업 > form').POST('[저장]', function (response) {
        if ($(this).getJson().isNew) {
          _branches(response, selected.find('>ul'))
        } else {
          $.extend(selected.menu, response)
          selected.toggleClass('namu--zombie', response.removal)
          .find('>a').text(response.name)
        }

        $.modalClose()
      })

      $('#메뉴구조_저장_버튼').click(function () {
        if ($.isEmptyObject(ordered)) {
          return $.toast.warn('메뉴구조를 변경 후 진행해 주세요.')
        }

        $.req.post('/_menu/all#[메뉴구조를 변경]', Object.keys(ordered).map(function (i) {
          return ordered[i]
        }))
        .done(function () {
          ordered = {}
        })
      })

      $('#권한').click('li', function (e) {
        $(e.target).closest('li').toggleClass('role--selected')
      })

      $('label[title=유형] > select').change(function () {
        $('.fn__bbs').toggle('00' === this.value)
        .next().attr('pattern', '00' === this.value ? '' : '[\w-]*')


        $('.fn__popup').toggle('01' === this.value)
      })
    </script>
    <script defer title="기능">
      function _menuDropEvent(e) {
        var li = $(e.target),
            menu = li.data('menu'),
            pid = (li.parent('ul').parent('li').data('menu') || {id: 0}).id

        if (menu.pid !== pid) {
          menu.pid = pid
          ordered[menu.id] = menu
        }

        _ordering(e.target)

        // 옮기기 이전에 있던 요소들 순서 맞추기
        e.target.family && e.target.family.next && _ordering(e.target.family.next)
      }

      function _branches(item, ul) {
        var li = $('<li draggable="true"><a>' + item.name + '</a>'),
            _ul = $('<ul/>')

        li.data('menu', item).toggleClass('namu--zombie', item.removal).append(_ul)
        ul.append(li)

        $.each(item.children, function (_i, i) {
          _branches(i, _ul)
        })

        return li
      }

      function _roleBranches(item, ul) {
        var _ul = $('<ul/>'),
            li = $('<li data-role=' + item.role + '>' +
                '<a title="' + item.description + '">' + item.role +
                '<span class="material-icons"></span></a></li>').append(_ul)

        $.each(item.children.filter(function (i) {
          return !i.removal
        }), function (_i, i) {
          _roleBranches(i, _ul)
        })

        ul.append(li.data('role', item))
        return li
      }

      function _ordering(el) {
        var li = $(el)
        do {
          var menu = li.data('menu'),
              index = li.index()

          if (menu.order !== index) {
            menu.order = index
            ordered[menu.id] = menu
          }
        } while ((li = li.next('li')).length)
      }
    </script>

    <style>
      .menu--selected > a,
      .role--selected > a {
        background-color: #09D;
        color: #FFF !important;
      }

      .role--selected > a .material-icons {
        font-size: 1.4rem;
        margin: -5px 0 0 8px;
      }

      .role--selected > a .material-icons::before {
        content: "\ef76"
      }

      h4 {
        margin-bottom: 1rem;
      }

      .fn__bbs,
      label[title].fn__popup {
        display: none;
      }
    </style>
</page:grid>
