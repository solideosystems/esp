<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:article title="공지사항">
    <header>
        <form id="검색_폼" action="/board/notice" class="app-search">
            <label title="검색어">
                <select name="type">
                    <option value="1">제목</option>
                    <option value="2">내용</option>
                    <option value="3">작성자</option>
                    <option value="">전체</option>
                </select>
            </label>
            <label title="">
                <input name="keyword">
            </label>
            <div class="app-button">
                <button id="조회_버튼" class="btn btn-default"></button>
                <button id="글쓰기_버튼" type="button" class="btn btn-primary"></button>
                <button id="삭제_버튼" type="button" class="btn btn-danger"></button>
            </div>
        </form>
    </header>

    <main>
        <section class="app--unary">
            <div id="공지사항_목록"></div>
        </section>
        <section id="공지사항_내용" class="app--unary">
            <div class=""></div>
        </section>
    </main>

    <figure id="입력_팝업" title="공지사항 입력/수정" class="app--popup">
        <form action="/board/notice">
            <input name="id" type="hidden">
            <input name="pid" type="hidden">
            <input name="author" type="hidden">
            <input name="email" type="hidden">
            <input name="password" type="hidden">

            <label title="제목">
                <input name="title">
            </label>

            <div id="notice-editor" class="editor"></div>

            <div id="입력_팝업_파일업로더"></div>

            <div class="app-button">
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    </figure>

    <script defer>
      var attachFiles = [], updating = false

      var grid = $('#공지사항_목록').grid({
        rownum: {
          name: '#', width: 100,
          valueGetter: 'node.rowIndex + 1',
          headerCheckboxSelection: true,
          checkboxSelection: true
        },
        title: {name: '제목', width: 500},
        author: {name: '작성자'},
        created: {
          name: '작성일시',
          valueGetter: function (params) {
            return new Date(params.data.created).format('yyyy-MM-dd')
          }
        }
      }, {
        rowSelection: 'multiple',
        onRowDoubleClicked: function (params) {
          $.req.get('/board/notice/' + params.data.id)
          .done(function (response) {
            updating = true
            attachFiles = response['attachFiles']

            $('#입력_팝업').editor(response)
            $('#입력_팝업_파일업로더').files(attachFiles)
          })
        },
        onPageNumberChanged: function (page, size) {
          $('#검색_폼').paginate(page, size);
        },
        onPageSizeChanged: function (page, size) {
          $('#검색_폼').paginate(page, size);
        }
      })

      $('#검색_폼').GET(grid.setData)

      $('#글쓰기_버튼').click(function () {
        updating = false
        attachFiles = []

        $('#입력_팝업').editor({})
        $('#입력_팝업_파일업로더').files(attachFiles)
      })

      $('#삭제_버튼').click(function () {
        var row = grid.getSelectedRow()
        row && confirm('삭제하시겠습니까?', function () {
          $.req.delete('/board/notice/' + row.id)
          .done(grid.remove)
        })
      })

      $('#입력_팝업 > form')
      .preprocess(function (params) {
        params.attachFiles = attachFiles
      })
      .POST(function (response) {
        $.modalClose()

        if (updating) {
          grid.update({
            title: response.title,
            content: response.content
          })
        } else {
          grid.add(response, 0)
        }
      })

      $('#입력_팝업_파일업로더')
      .on('file.add', function (e, data) {
        attachFiles = attachFiles.concat(data.files)
      })
      .on('file.remove', function (e, data) {
        $.each(data.files, function (i, file) {
          attachFiles
          .filter(function (i) {
            return i.id !== file.id
          })
          .map(function (i) {
            i.removal = true
            return i
          })
        })
      })
    </script>


    <!-- scoped styles -->
    <style></style>
</page:article>
