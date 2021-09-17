<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:grid title="{}">
    <header>
        <form id="검색입력" action="/___" class="app-search">
            <label title="항목1"><input name="item1" pattern="english"></label>
            <label title="항목2"><input name="item2"></label>
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
            <form id="상세입력" action="/___" class="app-details row">
                <input name="id" type="hidden">

                <div class="col-4">
                    <label title="항목1"><input name="item1"></label>
                    <label title="항목3"><input name="item3" type="date"></label>

                </div>
                <div class="col-4">
                    <label title="항목2"><input name="item2"></label>
                    <label title="항목4">
                        <input name="item4" data-view="item4Name" readonly>
                        <a class="material-icons">search</a>
                    </label>
                </div>
                <div class="col-4">
                    <div class="app-button">
                        <button id="생성_버튼" type="button" class="btn btn-default"></button>
                        <button id="삭제_버튼" type="button" class="btn btn-danger"></button>
                        <button id="저장_버튼" type="submit" class="btn btn-primary"></button>
                    </div>
                    <label title="항목5"><input name="item5"></label>
                </div>
            </form>
        </section>
    </main>

    <figure id="팝업" class="app--popup" title="어떤 팝업">
        <form action="/___/{id}/something">
            <!-- will be generated -->

            <div class="app-button">
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    </figure>

    <script defer title="그리드 정의">
      var grid = $('#목록').grid({
        rownum: {name: '#', width: 60, valueGetter: 'node.rowIndex + 1'},
        // {columns}
      }, {
        // 그리드 행 선택 이벤트
        onSelectionChanged: function (i) {
          $('#상세입력').clean().setJson(grid.getSelectedRow())
        },
        // 페이지 변경 이벤트
        onPageNumberChanged: function (page, size) {
          $('#검색입력').paginate(page, size);
        },
        // 그리드 표출 행의 갯수 변경 이벤트
        onPageSizeChanged: function (page, size) {
          $('#검색입력').paginate(page, size);
        }
      })
    </script>

    <script defer title="이벤트 정의">
      $('#검색입력').GET(function (response) {
        grid.setData(response)
      })

      $('#상세입력')
      .preprocess(function (params) { // submit 전처리
        if ($.isEmptyObject(params)) {
          return false // submit 이 막힘
        }
      })
      .POST('[저장]', function (response) {
        if (grid.getSelectedRow()) {
          grid.update(response)
        } else {
          grid.add(response)
        }
      })

      $('#생성_버튼').click(function () {
        grid.deselectAll()
        // TODO ...
      })

      $('#삭제_버튼').click(function () {
        var row = grid.getSelectedRow() || alert('목록에서 선택 후 진행 해 주세요.')
        if (!row) return false

        // TODO ...
      })

      $('#팝업 > form').POST(function (response) {
        _completed(response)
      })
    </script>

    <script defer title="기능">
      function _completed(data) {
        $.modalClose()
        console.info(data)
      }
    </script>
</page:grid>
