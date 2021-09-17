<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:grid title="사용자관리">
    <header>
        <form id="검색_폼" action="/system/user" class="app-search">
            <label title="사용자 ID"><input name="username" pattern="english"></label>
            <label title="이름"><input name="name"></label>
            <div class="app-button">
                <button id="조회_버튼" class="btn btn-default"></button>
            </div>
        </form>
    </header>

    <main>
        <section class="app--unary">
            <div id="목록"></div>
        </section>

        <section class="app--unary">
            <form id="상세_폼" action="/system/user" class="app-details app-details--grid">
                <input name="id" type="hidden">

                <div class="app-button">
                    <button id="생성_버튼" type="button" class="btn btn-default"></button>
                    <button id="비밀번호변경_버튼" type="button" class="btn btn-default"></button>
                    <button id="삭제_버튼" type="button" class="btn btn-danger"></button>
                    <button id="저장_버튼" type="submit" class="btn btn-primary"></button>
                </div>

                <label title="사용자 ID"><input name="username" readonly></label>
                <label title="이름"><input name="name"></label>
                <label title="조직">
                    <input name="teamId" data-view="teamName" data-modal="#조직찾기" readonly>
                    <a class="material-icons">search</a>
                </label>
                <label title="이메일"><input name="email"></label>
                <label title="직급">
                    <select name="grade">
                        <option></option>
                        <option>사원</option>
                        <option>대리</option>
                        <option>과장</option>
                        <option>차장</option>
                        <option>부장</option>
                    </select>
                </label>
                <label title="계정사용">
                    <input name="use" type="checkbox">
                    <br class="checkbox-tail">
                </label>
                <label title="비밀번호만료"><input name="passwordExpired" type="date"></label>
                <label title="입사일"><input name="hired" type="date"></label>
            </form>
        </section>
    </main>

    <figure id="비밀번호변경_팝업" class="app--popup" title="비밀번호 변경">
        <form action="/system/user/{id}/password#[비밀번호를 변경]">
            <input name="id" type="hidden">

            <label title="이전 비밀번호">
                <input name="oldPassword" type="password">
            </label>
            <label title="신규 비밀번호">
                <input name="newPassword" type="password">
            </label>
            <label title="비밀번호 확인">
                <input name="compareWith" type="password">
            </label>

            <div class="app-button">
                <button type="submit" class="btn btn-primary">변경</button>
            </div>
        </form>
    </figure>

    <figure id="조직찾기" class="app--popup" title="조직선택">
        <ul id="조직" class="namu"></ul>
        <div class="app-button">
            <button id="조직_선택취소_버튼" class="btn btn-default"></button>
        </div>
    </figure>

    <script defer>
      var grid = $('#목록').grid({
        rownum: {name: '#', width: 60, valueGetter: 'node.rowIndex + 1'},
        username: {name: '사용자ID'},
        name: {name: '이름'},
        teamName: {name: '조직'},
        grade: {name: '직급'},
        use: {
          name: '계정사용', width: 80, valueGetter: function (params) {
            return params.data.use ? '사용' : '미사용'
          }
        },
        passwordExpired: {name: '비밀번호만료', width: 120},
        hired: {name: '입사일', width: 100}
      }, {
        onSelectionChanged: function (i) {
          $('#상세_폼').clean().setJson(grid.getSelectedRow())
          .find('[name=username]')
          .prop('readonly', true)
        },
        onPageNumberChanged: function (page, size) {
          $('#검색_폼').paginate(page, size);
        },
        onPageSizeChanged: function (page, size) {
          $('#검색_폼').paginate(page, size);
        }
      })

      $.req.get('/_team')
      .done(function (response) {
        _branches(response, $('#조직'))
      })
    </script>
    <script defer title="이벤트">
      $('#검색_폼').GET(function (response) {
        grid.setData(response)
      })

      $('#상세_폼').POST('[저장]', function (response) {
        grid.getSelectedRow()
            ? grid.update(response)
            : grid.add(response)
      })

      $('#생성_버튼').click(function () {
        grid.deselectAll() && setTimeout(function () {
          $('#상세_폼').clean()
          .find('[name=username]')
          .removeAttr('readonly')
          .focus()
        })
      })

      $('#비밀번호변경_버튼').click(function () {
        var selected = grid.getSelectedRow()

        !selected
            ? $.toast.warn('목록에서 회원 선택 후 진행 해 주세요.')
            : $('#비밀번호변경_팝업').exec(
                function () {
                  $('[name=id]', this).val(selected.id)
                }).modal()
      })

      $('#비밀번호변경_팝업 > form').POST(function (response) {
        $.modalClose()
      })

      $('#삭제_버튼').click(function () {
        $.req.delete($('#상세_폼'))
      })

      $('#조직').on('click', 'a', function (e) {
        $('#상세_폼 [name=teamId]').setJson({
          teamId: $(this).data('id'),
          teamName: $(this).text()
        }) && $.modalClose()
      })

      $('#조직_선택취소_버튼').click(function () {
        $('#상세_폼 [name=teamId]').setJson({
          teamId: null,
          teamName: null
        }) && $.modalClose()
      })
    </script>
    <script defer>
      function _branches(item, ul) {
        var _ul = $('<ul/>'),
            li = $('<li><a data-id="' + item.id + '">' + item.name + '</a></li>').append(_ul)

        ul.append(li)
        $.each(item.children, function (_i, i) {
          _branches(i, _ul)
        })

        return li
      }
    </script>

    <!-- scoped styles -->
    <style>
      .app-search input {
        width: 120px;
      }

      .namu ul, .namu li {
        margin: 0;
        list-style: none;
        padding: 0;
        position: relative
      }

      .namu li {
        margin-left: 24px
      }

      .namu li::before {
        border-left: 1px solid #aaa;
        content: "";
        height: 100%;
        left: calc(24px * -1);
        position: absolute
      }

      .namu li::after {
        border-bottom: 1px solid #aaa;
        border-left: 1px solid #aaa;
        content: "";
        height: calc(24px / 2);
        left: calc(24px * -1);
        position: absolute;
        top: 0;
        width: 24px
      }

      .namu li:last-child::before {
        border: 0
      }

      .namu li > a {
        border-radius: 4px;
        box-sizing: border-box;
        display: inline-block;
        line-height: 24px;
        margin-left: 6px;
        padding: 0 4px;
        transition: all .4s
      }

      .namu--dragging {
        background-color: #eee;
        border: 1px dashed #aaa;
        border-radius: 4px;
        left: -1px
      }

      .namu--zombie {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' version='1.1' width='8' height='8' viewBox='0 0 8 8'%3E%3Cg%3E%3Cline style='stroke:rgb(220,220,220);stroke-width:1' x1='8' y1='0' x2='-0' y2='8' /%3E%3C/g%3E%3C/svg%3E");
        opacity: .5
      }

      .namu__knob {
        background-color: transparent;
        border: 2px solid #fff;
        height: calc(24px / 2 + 1px);
        left: calc(24px / 2 * -1);
        outline: 1px solid #aaa;
        padding: 0;
        position: absolute;
        top: 6px;
        width: calc(24px / 2 + 1px);
        z-index: 1
      }

      .namu__knob--purse {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' version='1.1' width='1' height='99' viewBox='0 0 1 99'%3E%3Cg%3E%3Cline style='stroke:rgb(170,170,170);stroke-width:1' x1='0' y1='0' x2='1' y2='99' /%3E%3C/g%3E%3C/svg%3E");
        background-position: 50% 50%;
        background-repeat: no-repeat
      }

      ul:empty + .namu__knob {
        display: none
      }
    </style>
</page:grid>
