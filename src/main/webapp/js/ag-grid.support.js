(function ($, ag) {

  $.fn.grid = function (columns, options) {
    this.addClass('app-grid ag-theme-alpine')

    if (undefined === options) {
      options = {}
    }

    options = $.extend(true, {
      columnDefs: Object.keys(columns).map(function (c) {
        var def = $.extend(columns[c], {
          field: c,
          headerName: columns[c].name
        })

        if (def.code) {
          $.fn.codes(def.code)

          if (!options.code) {
            options.code = {}
          }
          options.code[def.field] = def.code

          def.valueGetter = function (params) {
            var id = params.column.colId,
                value = params.data[id],
                result = ''

            $.each(top.env.codes[options.code[id]], function (i, cod) {
              if (cod.code === value) {
                result = cod.name
                return false
              }
            })

            return result
          }

          delete def.code
        }

        delete def.name
        return def
      }),
      rowData: options.rowData || [],
      headerHeight: 30,
      rowHeight: 30,
      suppressAutoSize: true,
      suppressCellSelection: true,
      defaultColDef: {
        resizable: true,
        minWidth: 50,
      },
      rowSelection: 'single',
      domLayout: 'autoHeight',
      animateRows: true,
      localeText: {
        noRowsToShow: '데이터가 없습니다.'
      }
    }, options)

    ag && new ag.Grid(this[0], options)

    //
    // extend functions
    //
    options.api.el = this

    options.api.getAllNodes = function () {
      var result = []
      options.api.forEachNode(function (i) {
        result.push(i)
      })

      return result
    }
    options.api.getRows = function (rowIndex) {
      if (rowIndex !== undefined) {
        var node = options.api.getRowNode(rowIndex)
        return node && node.data
      }

      var result = []
      options.api.forEachNode(function (i) {
        result.push(i.data)
      })

      return result
    }
    options.api.add = function (rowData, index) {
      var result = options.api.applyTransaction({
        add: [].concat(rowData),
        addIndex: index
      }).add.map(function (_node) {
        return $.extend(_node, {updated: true})
      })

      result[0].setSelected(true)

      return result
    }
    options.api.update = function (rowData, index) {
      var node = undefined === index
          ? options.api.getSelectedNodes()[0]
          : options.api.getRowNode(index)

      if (!node) {
        return
      }

      var result = options.api.applyTransaction({
        update: [$.extend(true, node.data, rowData)]
      }).update.map(function (_node) {
        return $.extend(_node, {updated: true})
      })

      options.api.deselectAll()
      node.setSelected(true)

      return result
    }
    options.api.remove = function (index) {
      var node = typeof index !== 'number'
          ? grid.getSelectedRows()
          : [(grid.getRowNode(index) || {}).data]

      node[0] && options.api.applyTransaction({
        remove: node
      })
    }

    options.api.select = function (index) {
      var node = options.api.getRowNode(index)
      node && node.setSelected(true)
    }

    options.api.getUpdatedRows = function () {
      return options.api.getAllNodes()
      .filter(function (node) {
        return node.updated
      })
      .map(function (node) {
        return node.data
      })
    }
    options.api.getSelectedRow = function (index) {
      var selected = options.api.getSelectedRows()
      return selected.length ? selected[index || 0] : null
    }
    options.api.setData = function (data) {
      if ($.isArray(data)) {
        options.api.setRowData(data)
      } else if (data.hasOwnProperty('pageable') &&
          data.hasOwnProperty('content')) {
        options.api.setRowData(data.content)

        if (!options.api.el.next('.ag-pagination').length) {
          options.api.el.after(
              '<div class="ag-pagination"><label class="ag-pagination__page" data-total-page="0"><input type="number"></label><label class="ag-pagination__rows"><select><option>10</option><option>20</option><option>30</option><option>50</option></select></label></div>')
        }

        var pagination = options.api.el.next('.ag-pagination'),
            rows = $('.ag-pagination__rows > select', pagination),
            page = $('.ag-pagination__page > input', pagination)

        rows
        .change(function () {
          options.onPageSizeChanged &&
          options.onPageSizeChanged(parseInt(page.val()) - 1,
              parseInt(rows.val()))
        })

        $('.ag-pagination__page', pagination)
        .attr('data-total-page', data.totalPages)
        .find('input').val(data.number + 1)
        .attr('max', data.totalPages)
        .off('change')
        .change('input', function () {
          if (this.value > data.totalPages) {
            this.value = data.totalPages
          } else if (this.value < 1) {
            this.value = 1
          }

          if ((this.beforeValue || '1') !== this.value) {
            this.beforeValue = this.value

            options.onPageNumberChanged &&
            options.onPageNumberChanged(parseInt(page.val()) - 1,
                parseInt(rows.val()))
          }
        })
      }
    }

    return options.api
  }

  ag.editor = {
    numeric: function (i) {
      setTimeout(function () {
        $('input', i.eGridCell).attr('type', 'number')
      }, 100)
    }
  }

  ag.render = {
    checkbox: new Function()
  }
  ag.render.checkbox.prototype = {
    init: function (params) {
      this.params = params;

      this.eGui = document.createElement('input');
      this.eGui.type = 'checkbox';
      this.eGui.checked = params.value;

      this.checkedHandler = this.checkedHandler.bind(this);
      this.eGui.addEventListener('click', this.checkedHandler);
    },
    checkedHandler: function (e) {
      var checked = e.target.checked;
      var colId = this.params.column.colId;
      this.params.node.setDataValue(colId, checked);
    },
    getGui: function () {
      return this.eGui;
    },
    destroy: function () {
      this.eGui.removeEventListener('click', this.checkedHandler);
    }
  }

  ag.component = {
    checkbox: function () {
      this.tag = document.createElement('label')
    }
  }
  ag.component.checkbox.prototype = {
    init: function (params) {
      this.checkbox = document.createElement('input')
      this.checkbox.type = 'checkbox'
      this.tag.appendChild(this.checkbox)
      this.tag.setAttribute('data-name', params.displayName)

      this.checkbox.addEventListener('change', function (e) {
        var checked = e.target.checked
        var colId = params.column.colId

        params.api.forEachNode(function (node) {
          if (node.data[colId] !== checked) {
            node.setDataValue(colId, checked);
          }
        })
      })
    },
    getGui: function () {
      return this.tag;
    }
  }

}(jQuery, agGrid))
