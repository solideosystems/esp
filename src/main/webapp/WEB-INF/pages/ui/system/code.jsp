<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:grid title="코드관리">
    <header>
        <form id="검색_폼" class="app-search">
            <label title="시스템">
                <select name="group" data-code="SYSTEMS"></select>
            </label>
            <div class="app-button">
                <button id="조회_버튼" class="btn btn-default"></button>
                <button id="저장_버튼" type="button" class="btn btn-primary"></button>
            </div>
        </form>
    </header>

    <main>
        <section class="app--column">
            <div>
                <div class="app-inline-form">
                    <label title="검색">
                        <input id="그룹_검색">
                    </label>

                    <div class="app-button">
                        <button data-modal="#그룹_입력_팝업" class="btn btn-light">생성</button>
                    </div>
                </div>
                <div>
                    <div id="그룹_리스트"></div>
                </div>
            </div>
            <div>
                <div class="app-inline-form">
                    <label title="검색">
                        <input id="코드_검색">
                    </label>
                    <div class="app-button">
                        <button data-modal="#코드_입력_팝업" class="btn btn-light" disabled>생성</button>
                    </div>
                </div>
                <div>
                    <div id="코드_리스트"></div>
                </div>
            </div>
        </section>
    </main>

    <figure id="그룹_입력_팝업" class="app--popup" title="새로운 그룹">
        <form action="/_code">
            <label title="그룹 코드">
                <input name="code">
            </label>
            <label title="그룹 이름">
                <input name="name">
            </label>

            <div class="app-button">
                <button type="submit" class="btn btn-primary">만들기</button>
            </div>
        </form>
    </figure>

    <figure id="코드_입력_팝업" class="app--popup" title="새로운 코드 입력">
        <form action="/_code">
            <label title="코드">
                <input name="code" required>
            </label>
            <label title="코드 이름">
                <input name="name">
            </label>
            <label title="순서">
                <input name="order" type="number">
            </label>
            <label title="사용여부">
                <input name="use" type="checkbox">
            </label>

            <div class="app-button">
                <button type="submit" class="btn btn-primary">만들기</button>
            </div>
        </form>
    </figure>


    <script defer title="Grid 정의">
      var updated = {}

      var grid = {
        group: $('#그룹_리스트').grid({
          code: {name: '그룹 코드', editable: true, width: 100},
          name: {name: '그룹 이름', editable: true, width: 300},
          use: {
            name: '사용여부',
            width: 100,
            cellRenderer: agGrid.render.checkbox,
            headerComponent: agGrid.component.checkbox
          }
        }, {
          onSelectionChanged: function () {
            var row = grid.group.getSelectedRow()
            row && _getCodes(row.code, function (codes) {
              grid.codes.setRowData(codes)
              $('button[disabled]').disabled(false)
            })
          },
          onCellValueChanged: function (params) {
            var row = params.data,
                col = params.column

            if (!params.newValue && col.colId.match(/code|name/)) {
              row[col.colId] = params.oldValue
              grid.group.update(row)
            }

            updated[row.id] = row
          }
        }),
        codes: $('#코드_리스트').grid({
          code: {name: '코드', width: 100, editable: true},
          name: {name: '코드 이름', editable: true},
          order: {name: '순서', width: 70, editable: true, cellEditorSelector: agGrid.editor.numeric},
          use: {
            name: '사용여부',
            width: 100,
            cellRenderer: agGrid.render.checkbox,
            headerComponent: agGrid.component.checkbox
          }
        }, {
          onCellValueChanged: function (params) {
            var row = params.data,
                col = params.column

            if (!params.newValue && col.colId.match(/code|name/)) {
              row[col.colId] = params.oldValue
              grid.codes.update(row)
            }

            updated[row.id] = row
          }
        })
      }
    </script>

    <script defer title="이벤트 정의">
      $('#검색_폼').submit(function (e) {
        e.preventDefault()

        _getCodes($('[name=group]', this).val(), function (codes) {
          grid.group.setRowData(codes)
        })
      })
      .find('select').change($('#검색_폼').submit)

      $('#저장_버튼').click(function () {
        !$.isEmptyObject(updated) &&
        confirm('{저장}', function () {
          $.req.post('/_code/all', Object.keys(updated).map(i => updated[i]))
          .done(function () {
            updated = {}
          })
        })
      })

      $('#그룹_입력_팝업 > form')
      .preprocess(function (params) {
        params.group = $('[name=group]').val()
      })
      .POST(function (response) {
        grid.group.add(response)
        $.modalClose()
      })

      $('#코드_입력_팝업 > form')
      .preprocess(function (params) {
        params.group = grid.group.getSelectedRow().code
      })
      .POST(function (response) {
        grid.codes.add(response)
        $.modalClose()
      })

      $('#그룹_검색').keyup(function () {
        $.debounce(function () {
          grid.group.setRowData(_filterCodes($('[name=group]').val(), this.value))
        }.bind(this))
      })

      $('#코드_검색').keyup(function () {
        var row = grid.group.getSelectedRow()
        $.debounce(function () {
          grid.codes.setRowData(_filterCodes(row.code, this.value))
        }.bind(this))
      })
    </script>

    <script defer title="기능 정의">
      function _getCodes(group, fn) {
        $.req.get('/_code/' + group)
        .done(function (response) {
          top.env.codes[group] = response
          fn(response)
        })
      }

      function _filterCodes(group, keyword) {
        console.log(group, keyword, top.env.codes[group])
        return !group || !top.env.codes[group] ? [] :
            top.env.codes[group].filter(function (i) {
              return !keyword || i.code.indexOf(keyword) > -1 || i.name.indexOf(keyword) > -1
            })
      }
    </script>
</page:grid>
