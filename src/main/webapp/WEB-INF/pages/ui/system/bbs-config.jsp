<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:grid title="게시판관리">
    <main>
        <section class="app--unary">
            <div id="게시판_목록"></div>
        </section>

        <section class="app--unary">
            <form id="게시판_상세_폼" action="/system/bbs-config" class="app-details app-details--grid">
                <input name="id" type="hidden">

                <div class="app-button">
                    <button id="새로만들기_버튼" type="button" class="btn btn-secondary"></button>
                    <button id="삭제_버튼" type="button" class="btn btn-danger"></button>
                    <button id="저장_버튼" type="submit" class="btn btn-primary"></button>
                </div>

                <label title="ID"><input name="category" required readonly></label>
                <label title="설명"><input name="description"></label>
                <label title="유형">
                    <select name="type" data-code="BBS_TYPE">
                        <option></option>
                    </select>
                </label>
                <label title="코멘트 허용">
                    <input name="props.usage.comment" type="checkbox">
                </label>
                <label title="자동 비밀글">
                    <input name="props.usage.defaultSecret" type="checkbox">
                </label>
                <label title="NEW 기간">
                    <input name="props.rule.newPeriod" type="number">
                    <em>(일 단위)</em>
                </label>
                <label title="HOT 조회수">
                    <input name="props.rule.hotCeiling" type="number">
                </label>
                <label title="목록 출력수">
                    <input name="props.page.size" type="number">
                </label>
                <label title="페이지 출력수">
                    <input name="props.page.range" type="number">
                </label>
            </form>
        </section>
    </main>

    <script defer>
      var grid = $('#게시판_목록').grid({
        rownum: {name: '#', width: 60, valueGetter: 'node.rowIndex + 1'},
        category: {name: 'ID'},
        type: {name: '유형', code: 'BBS_TYPE'},
        description: {name: '설명', width: 400}
      }, {
        onGridReady: function () {
          $.req.get('/system/bbs-config')
          .done(function (json) {
            grid.setData(json)
          })
        },
        onSelectionChanged: function () {
          var row = grid.getSelectedRow()
          $('#게시판_상세_폼').clean().setJson(row)
        }
      })

      $('#게시판_상세_폼').POST('[저장]', function (response) {
        console.log(response)
      }, function (params) {
        if (!params.category) {
          alert('ID 를 입력해 주세요.')
          return false
        }
      })

      $('#새로만들기_버튼').click(function () {
        $('#게시판_상세_폼').clean()
        .find('[name=category]')
        .removeAttr('readonly')
        .focus()
      })

      $('#삭제_버튼').click(function () {
        grid.getSelectedRow() &&
        confirm('삭제 하시겠습니까?', function () {
          grid.remove()
        })
      })
    </script>


    <!-- scoped styles -->
    <style>
      .app-search input {
        width: 120px;
      }
    </style>
</page:grid>
