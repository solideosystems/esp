<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:grid title="조직관리">
    <main>
        <section class="app--column">
            <div>
                <div class="btn-group float-right">
                    <button id="하위조직_추가_버튼" class="btn btn-default" disabled></button>
                    <button id="조직구조_저장_버튼" class="btn btn-default" disabled></button>
                </div>
                <h4>조직 구조</h4>
                <ul id="조직"></ul>
            </div>
            <div>
                <button id="권한_저장_버튼" class="btn btn-default float-right" disabled></button>
                <h4>할당된 권한</h4>
                <ul id="권한" class="authority namu"></ul>
            </div>
        </section>
    </main>

    <figure id="조직입력_팝업" class="app--popup" title="조직 정보 입력">
        <form action="/_team">
            <label title="상위 조직">
                <input name="pid" data-view="parentName" readonly>
            </label>
            <label title="이름">
                <input name="name" required>
            </label>
            <label title="삭제여부">
                <input name="removal" type="checkbox">
            </label>

            <div class="app-button">
                <button class="btn btn-primary">저장</button>
            </div>
        </form>
    </figure>

    <script src="${pageContext.request.contextPath}/js/namu.min.js"></script>
    <script defer>
      var selected = null,
          updating = false,
          ordered = {},
          authorities = [],
          authorized = []

      $.req.get('/_team')
      .done(function (json) {
        var ul = $('#조직')

        json.children.forEach(function (i) {
          _branches(i, ul)
        })

        namu(ul[0]).drop(_teamDropEvent)
      })

      $.req.get('/_authority/team')
      .done(function (json) {
        authorized = json
      })

      $.req.get('/_authority?id=0')
      .done(function (json) {
        authorities = json
        _roleBranches(authorities, $('#권한'))
      })
    </script>
    <script defer title="이벤트">
      $('#하위조직_추가_버튼').click(function () {
        $('#조직입력_팝업').modal({
          onOpen: function () {
            updating = false

            $('#조직입력_팝업 > form').setJson({
              pid: selected.team.id,
              parentName: selected.team.name,
              order: selected.children('ul').has('li').length
            })
          }
        })
      })

      $('#조직입력_팝업 > form')
      .preprocess(function (params) {
        console.log(params)
        if (updating && params.removal && !params.pid) {
          alert('최상위 조직은 삭제 할 수 없습니다.')
          return false
        }
      })
      .POST('[저장]', function (response) {
        if (updating) {
          $.extend(selected.team, response)
          selected.find('>a').text(response.name)

          response.removal && selected.fadeOut(function() {
            this.remove()
          }).parent().parent().click()
        } else {
          !response.removal && _branches(response, selected.children('ul'))
        }

        $.modalClose()
      })

      $('#조직구조_저장_버튼').click(function () {
        $.isEmptyObject(ordered) &&
        $.req.post('/_team/all#[변경된 구조를 저장]', Object.keys(ordered)
        .map(function (i) {
          return ordered[i]
        }))
        .done(function (response) {
          ordered = {}
          $('#조직구조_저장_버튼').disabled(true)
        })
      })

      $('#권한_저장_버튼').click(function () {
        confirm('{저장}', function () {
          $.req.post('/_authority/team/' + selected.team.id, selected.authorize)
          .done(function (response) {
            authorized[selected.team.id] = response
          })
        })
      })

      $('#조직').click('li', function (e) {
        selected && selected.removeClass('team--selected')
        selected = $(e.target).closest('li').addClass('team--selected')
        selected.team = selected.data('team')
        selected.authorize = authorized[selected.team.id]

        $('#권한 .role--selected').removeClass('role--selected')
        $.each(selected.authorize, function (i, authority) {
          $('#권한 li[data-role=' + authority.role + ']')
          .addClass('role--selected')
        })

        $('#하위조직_추가_버튼,#권한_저장_버튼').disabled(false)
      })
      .dblclick('li', function (e) {
        $('#조직입력_팝업').modal({
          onOpen: function () {
            updating = true

            $('#조직입력_팝업 > form').setJson($.extend(selected.team, {
              parentName: ($(e.target).closest('li').parent().parent().data('team') || {}).name
            }))
          }
        })
      })

      $('#권한').click('li', function (e) {
        var li = $(e.target).closest('li'),
            isOn = li.is('.role--selected'),
            target = li

        while ((target =
            target.removeClass('role--selected').closest('.role--selected')).length) {
          // empty
        }

        li.addClass(isOn ? '' : 'role--selected')
        .find('.role--selected').removeClass('role--selected')

        selected && (selected.authorize = []) &&
        $('.role--selected', this).each(function (_i, i) {
          selected.authorize.push($(i).data('role'))
        })
      })
    </script>
    <script defer title="기능">
      function _teamDropEvent(e) {
        var li = $(e.target),
            team = li.data('team'),
            pid = (li.parent('ul').parent('li').data('team') || {id: 0}).id

        if (team.pid !== pid) {
          team.pid = pid
          ordered[team.id] = team
          $('#조직구조_저장_버튼').disabled(false)
        }

        _ordering(e.target)

        // 옮기기 이전에 있던 요소들 순서 맞추기
        e.target.family && e.target.family.next && _ordering(e.target.family.next)
      }

      function _branches(item, ul) {
        var _ul = $('<ul/>'),
            li = $('<li draggable="true"><a>' + item.name + '</a></li>').append(_ul)
            .data('team', item)

        $.each(item.children, function (_i, i) {
          _branches(i, _ul)
        })

        ul.append(li)

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
          var team = li.data('team'),
              index = li.index()

          if (team.order !== index) {
            team.order = index
            ordered[team.id] = team
          }
        } while ((li = li.next('li')).length)
      }

      function toList(item) {
        var list = [item]

        $.each(item.children, function (i, child) {
          list = list.concat(
              toList($.extend(child, {parentName: item.name, depth: item.depth + 1 || 1})))
        })

        return list
      }
    </script>

    <style>
      .team--selected > a,
      .role--selected a {
        background-color: #09D;
        color: #FFF !important;
      }


      .authority .role--selected > a .material-icons {
        font-size: 1.4rem;
        margin: -5px 0 0 8px;
      }

      .authority .role--selected > a .material-icons::before {
        content: "\ef76"
      }

      h4 {
        margin-bottom: 1rem;
      }
    </style>
</page:grid>
