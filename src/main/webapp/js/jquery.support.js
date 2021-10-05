'use strict'

if (!top.env) {
  top.env = {
    codes: {},
    menu: [],
    active: {
      gnb: true,
      menu: null
    }
  }
}

if (!top._wip) {
  top._wip = {
    jobs: [],
    count: 0,
    add: function (fn) {
      top._wip.jobs.push(fn)
    },
    increase: function (fn) {
      fn && top._wip.jobs.push(fn)
      this.count++
    },
    flush: function () {
      if (top._wip.count > 0) {
        setTimeout(top._wip.flush, 100)
      } else if (top._wip.jobs.length) {
        top._wip.jobs.forEach(function (job) {
          $(function () {
            job.call($, null)
          })
        })
        top._wip.jobs = []
      }
    },
    decrease: function () {
      if (--this.count < 1) {
        this.flush()
      }
    }
  }
}

$.alert && (window.alert = function (message, title) {
  $.alert({
    title: title || '',
    content: message,
    escapeKey: true,
    backgroundDismiss: true
  })
})

$.confirm && (window.confirm = function (message, titleOrButtons, buttons) {
  if ($.isPlainObject(titleOrButtons)) {
    buttons = titleOrButtons
  }

  if (/^{.+}$/.test(message)) {
    $.jobName = message.substring(1, message.length - 1)
    message = $.jobName + ' 하시겠습니까?'
  }

  var defaultOk = $.isFunction(titleOrButtons) ? titleOrButtons : null

  window.confirm.c = $.confirm({
    title: typeof titleOrButtons === 'string' ? titleOrButtons : '',
    content: message,
    buttons: buttons || {
      'OK': {
        text: '확인',
        btnClass: 'btn-primary',
        action: function () {
          defaultOk && defaultOk()
          window.confirm.c.close()
        }
      },
      'CANCEL': {
        text: '취소',
        btnClass: 'btn-light',
        action: function () {
          window.confirm.c.close()
        }
      }
    }
  })
})

// -------------------------------------------------------
// Initialize
// -------------------------------------------------------
$(function () {
  $('select[data-code]').each(function (i, el) {
    top._wip.increase()
    $(el).codes(el.getAttribute('data-code'))
  })

  $('button[id]').each(function (i, el) {
    !$.trim(el.innerHTML)
    && $(el).text(el.id.replace(/_/g, ' ').replace(/\s+버튼$/, ''))
  })

  $('input[pattern]').each(function (i, el) {
    var pattern = el.getAttribute('pattern')
    if ('english' === pattern) {
      $(el).on('keyup', function () {
        if (!/^[a-zA-Z\s]$/.test(this.value)) {
          this.value = this.value.replace(/[^a-zA-Z\s]/g, '')
        }
      })

      el.removeAttribute('pattern')
    }
  })

  $.loaded(function () {
    // 모달 팝업 띄우기
    $('input,button').filter('[data-modal]').click(function () {
      $(this.getAttribute('data-modal')).modal()
    })

    // 기본 검색 기능은 페이지 접근 하면 바로 실행
    $('form.app-search')
    .submit(function (e) {
      e.preventDefault()
    })
    .submit()
  })

  top._wip.flush()
})

// -------------------------------------------------------
// Functions
// -------------------------------------------------------
;(function ($) {
  var _progress = 0

  $(document)
  .ajaxSend(function (e, xhr, settings) {
    ++_progress
    console.info('_progress: ' + _progress, e)

    if ($.jobName) {
      settings.jobName = $.jobName
      delete $.jobName
    } else if (/#\[.+]$/.test(settings.url)) {
      settings.jobName = settings.url.replace(/.+#\[(.+)]$/, '$1')
    }
  })
  .ajaxError(function (e, xhr) {
    if (--_progress < 1) {
      console.info('end of process')
    }
  })
  .ajaxComplete(function (e, xhr, settings) {
    if (--_progress < 1) {
      console.info('end of process')
    }

    if (settings.jobName && xhr.status >= 200 && xhr.status < 300) {
      $.toast(settings.jobName + ' 하였습니다.')
    }
  })

  $.req = (function () {
    function request(data, url, json) {
      if ('string' !== typeof url) {
        var form = $(url)
        if (!form.is('form')) {
          throw new Error('url requires string or <form/>')
        }

        url = form.attr('action')
        json = $.extend(json, form.getJson())
      }

      return $.extend(data, {
        url: url.replace(/{(\w+)}/g, function (_i, i) {
          return json[i] || _i
        }),
        data: JSON.stringify(json),
        contentType: 'application/json',
      })
    }

    return {
      get: function (url) {
        return $.ajax(url)
      },
      patch: function (url, json) {
        return $.ajax(request({
          method: 'patch'
        }, url, json))
      },
      multipart: function (files) {
        var formData = new FormData()
        $.each($.makeArray(files), function (i, file) {
          formData.append('file' + i, file)
        })

        return $.ajax({
          method: 'post',
          url: '/_file',
          data: formData,
          contentType: false,
          processData: false
        })
      },
      post: function (url, json) {
        return $.ajax(request({
          method: 'post',
        }, url, json))
      },
      delete: function (url, json) {
        return $.ajax(request({
          method: 'delete'
        }, url, json))
      }
    }
  })()

  $.fn.exec = function (fn) {
    return false === fn.call(this) ? false : this
  }

  function _setJsonValueSetter(el, json, convert) {
    var name = el.getAttribute('name'),
        paths = name.split('.'),
        value = json[name]

    if (paths.length > 1) {
      value = json
      $.each(paths, function (_, path) {
        if (value) {
          if (!value.hasOwnProperty(path)) {
            value = ''
            return false
          }

          value = value[path]
        }
      })
    }

    if ('checkbox' === el.type) {
      el.checked = convert && convert[name] && convert[name](value) || !!value
    } else {
      el.value = convert && convert[name] && convert[name](value)
          || (value === 0 ? 0 : (value || ''))
    }

    var dataView = el.getAttribute('data-view')
    if (dataView) {
      if ('checkbox' !== el.type) {
        $(el).data('raw', JSON.stringify(el.value))
        .val(convert && convert[dataView] &&
            convert[dataView](json[dataView]) ||
            (json[dataView] === 0 ? 0 : (json[dataView] || '')))
      }
    }
  }

  $.fn.setJson = function (json, convert) {
    if (this.is('input,select,textarea')) {
      var form = this.closest('form')
      form.data('raw', $.extend(form.data('raw'), json))

      _setJsonValueSetter(this[0], json, convert)

      return this
    }

    this.data('raw', json)

    if (!this.is('form') || !json) {
      return this
    }

    $('[name]', this).each(function (i, el) {
      _setJsonValueSetter(el, json, convert)
    })

    return this
  }

  $.fn.getJson = function () {
    if (!this.is('form')) {
      return
    }

    var json = $.extend(true, this.data('raw'), {})
    $('[name]', this).each(function (i, el) {
      var name = el.getAttribute('name'),
          context = json

      if (name.indexOf('\.') > 0) {
        var paths = name.split('.')

        name = paths.splice(-1)
        $(paths).each(function (_, path) {
          !context[path] && (context[path] = {})
          context = context[path]
        })
      }

      var data = $(el).data()
      if (data.raw) {
        context[name] = JSON.parse(data.raw)
        data.view && (context[data.view] = el.value)
      } else if ('checkbox' === el.type) {
        context[name] = el.checked
      } else {
        context[name] = /number/.test(el.type)
            ? (parseInt(el.value) || 0)
            : el.value
      }
    })

    return json
  }

  $.fn.clean = function (maintainValues) {
    if (this.is('form')) {
      $('.app-errors', this).remove()
      $('label[data-error]', this).removeAttr('data-error')

      if (!maintainValues) {
        $('[name]', this).each(function (i, el) {
          var init = el.getAttribute('data-init'),
              type = el.type

          if (/checkbox|radio/.test(type)) {
            el.checked = /y|on|t/i.test(init)
          } else {
            el.value = init ? init : ''
          }
        })

        if (window.CKEDITOR && this.find('.cke').length) {
          var editorId = this.find('.cke').attr('id').replace(/^cke_/, '')
          CKEDITOR.instances[editorId].setData('')
        }

      }
    }

    return this
  }

  $.fn.preprocess = function (fn) {
    this.preprocess = fn
    return this
  }

  $.fn.GET = function (callback) {
    if (!this.is('form[action]')) {
      console.error('$(...).GET() only use in <form [action]/> tag')
      return
    }

    var form = this

    form.off()
    .submit(function (e) {
      e.preventDefault()

      var params = form.serializeArray().reduce(function (a, b) {
        a[b.name] = b.value
        return a
      }, {})

      if ($.isFunction(form.preprocess) && false === form.preprocess(params)) {
        return false
      }

      var url = form.attr('action')

      url = url.replace(/{(\w+)}/g, function (origin, variable) {
        return params[variable] || origin
      })

      url += url.indexOf('?') > 0 ? '&' : '?'
      url += Object.keys(params).map(function (i) {
        return i + '=' + encodeURIComponent(params[i])
      }).join('&')

      form.data('pageNumber') && (url += '&page=' + form.data('pageNumber'))
      form.data('pageSize') && (url += '&size=' + form.data('pageSize'))

      $.req.get(url)
      .done(function (response) {
        callback(response)
      })
    })

    return this
  }

  $.fn.paginate = function (page, size) {
    if (!this.is('form[action]')) {
      console.error('$(...).page() only use in <form [action]/> tag')
      return
    }

    this.data({
      pageIndex: page,
      pageSize: size
    }).submit()
  }

  $.fn.POST = function (message, callback) {
    if (!this.is('form[action]')) {
      console.error('$(...).POST() only use in <form [action]/> tag')
      return
    }

    var form = this

    if ($.isFunction(message)) {
      callback = message
      message = form.find('button[type=submit]')
      .add(form.find('button:not([type])')).eq(0)
      .text()
      message && (message = '[' + message + ']')
    }

    form.off()
    .submit(function (e) {
      e.preventDefault()

      form.clean(true)

      var params = form.getJson()

      if (window.CKEDITOR && form.find('.cke').length) {
        var editorId = form.find('.cke').attr('id').replace(/^cke_/, '')
        params.content = CKEDITOR.instances[editorId].getData()
      }

      if ($.isFunction(form.preprocess) && false === form.preprocess(params)) {
        return false
      }

      var request = function () {
        $.req.post(form.attr('action'), params)
        .done(function (response) {
          callback.call(form, response)
          form.clean()
        })
        .fail(function (xhr) {
          var errors = []

          if (400 === xhr.status) {
            errors.concat(JSON.parse(xhr.responseText)).forEach(function (i) {
              var input = $('[name=' + i.field + ']', form)
              if (!input.length) {
                errors.push(i.defaultMessage)
              } else {
                input.parent('label').attr('data-error', i.defaultMessage)
              }
            })
          } else if (500 === xhr.status) {
            var error = JSON.parse(xhr.responseText)
            errors.push([error.message, error.exception].join(' - '))
          }

          _showFormError(form, errors)
        })
      }

      if (!message) {
        request()
      } else {
        if (/^\[.+]$/.test(message)) {
          $.jobName = message.replace(/^\[(.+)]$/, '$1')
          message = $.jobName + ' 하시겠습니까?'
        }

        confirm(message, request)
      }
    })
    .find('[pattern]').on('invalid', function (e) {
      var warning = this.getAttribute('aria-label')
      warning && this.setCustomValidity(this.validity.patternMismatch
          ? warning
          : '')
    })

    return this
  }

  function _showFormError(form, messages) {
    var container = $('<ul class="app-errors"/>')
    form.prepend(container)

    $(messages).each(function (i, message) {
      container.append('<li>' + message + '</li>')
    })
  }

  $.fn.editor = function (data) {
    if (!(this[0].nextSibling && 'editor-hometown'
        === this[0].nextSibling.textContent)) {
      this.after('<!--editor-hometown-->')
    }

    var _this = this
    var target = _this[0].nextSibling
    var editor

    _this.find('form').setJson(data)

    return $.dialog({
      title: this.attr('title'),
      content: '',
      columnClass: 'col-md-12 col-lg-10',
      onContentReady: function () {
        $.fn.modal.eggs.push(this)
        this.$content.append(_this)
      },
      onOpen: function () {
        editor = CKEDITOR.replace(_this.find('.editor').attr('id'))
        editor.setData(data && data.content)
      },
      onClose: function () {
        $(target).before(this.$content.children('[id]'))
        editor && editor.destroy(true)
      },
      onDestroy: function () {
        $.modalClose()
      }
    })
  }

  $.fn.modal = function (options) {
    if (!(this[0].nextSibling && 'modal-hometown'
        === this[0].nextSibling.textContent)) {
      this.after('<!--modal-hometown-->')
    }

    var _this = this
    var hometown = $(_this[0].nextSibling)
    var closeCallback = options && options.onClose

    return $.dialog($.extend(options, {
      title: this.attr('title'),
      content: '',
      columnClass: options && options.size === 'lg' ? 'col-md-12 col-lg-10'
          : 'col-md-8 col-lg-6',
      onContentReady: function () {
        $.fn.modal.eggs.push(this)
        this.$content.append(_this)
      },
      onClose: function () {
        hometown.before(this.$content.find('figure'))
        $.isFunction(closeCallback) && closeCallback.call(this)
      },
      onDestroy: function () {
        $.modalClose()
      }
    }))
  }
  $.fn.modal.eggs = []

  $.modalClose = function (fn) {
    $.fn.modal.eggs.forEach(function (egg) {
      egg.close()
    })

    $.fn.modal.eggs = []

    $.isFunction(fn) && fn()
  }

  $.fn.codes = function (group) {
    if (top.env.codes[group]) {
      _codes(this, top.env.codes[group])
    } else {
      $.ajax({
        url: '/_code/' + group,
        async: false
      })
      .done(function (response) {
        top.env.codes[group] = response
        _codes(this, response)
      }.bind(this))
      .always(function () {
        top._wip.decrease()
      })
    }
  }

  $.fn.files = function (files) {
    var _this = this,
        add = function (file) {
          $('.app-attaches__list', _this).append(
              ['<li><a href=/_file/', file.id, '>',
                file.name, ' (', $.fileSize(file.size), ')',
                '</a><button type="button" class="btn btn-sm btn-default ml-2" id="',
                file.id, '">삭제</button></li>'
              ].join(''))
        },
        load = function (fileList) {
          $.req.multipart(fileList)
          .done(function (response) {
            Object.keys(response).forEach(function (i) {
              add(response[i])
              files.push(response[i])
            })
          })
        }

    _this.empty().off()
    .addClass('app-attaches')
    .append('<ul class="app-attaches__list"></ul>'
        + '<label title="파일업로드"><input type="file"></label>')
    .on('dragover', function (e) {
      e.preventDefault()
    })
    .on('drop', function (e) {
      e.preventDefault()
      load(e.originalEvent.dataTransfer.files)
    })
    .find('.app-attaches__list')
    .on('click', 'a', function (e) {
      e.preventDefault()
      e.stopPropagation()
      $.download(this.href)
    })
    .on('click', 'button', function (e) {
      e.preventDefault()
      e.stopPropagation()

      $(this).exec(function () {
        var id = this.attr('id')
        files.some(function (file) {
          return file.id === id && (file.removal = true)
        })
      })
      .closest('li')
      .remove()
    })
    .next().find('input[type=file]')
    .on('drop', function (e) {
      e.preventDefault()
    })
    .change(function () {
      load(this.files)
      this.value = ''
    })

    files && $.each(files, function (i, file) {
      add(file)
    })

    return this
  }

  function _codes(select, codes) {
    $.each(codes, function (i, code) {
      code.use && select.append(
          ['<option value="', code.code, '">', code.name, '</option>'].join('')
      )
    })

    if (select.attr('data-init')) {
      select.val(select.attr('data-init'))
    }

    select.removeAttr('data-code')
  }

// --------------------------------------------------
// global functions
// --------------------------------------------------
  $.loaded = function (fn) {
    top._wip.add(fn)
  }

  $.debounce = function (fn, milli) {
    clearTimeout($.debounce.on)
    $.debounce.on = setTimeout(fn.bind(this), milli || 400)

    return fn
  }

  $.download = function (url) {
    var frame = document.createElement('iframe')
    frame.setAttribute('src', url)
    frame.style.opacity = '0'
    $(document.body).append(frame)

    setTimeout(function () {
      $(frame).remove()
    }, 1000)
  }

  $.fileSize = function (size) {
    var units = ['bytes', 'KB', 'MB', 'GB', 'TB'],
        count = 0

    if (size < 1000) {
      return size + ' ' + units[0];
    }

    while ((size = (size || 0) / 1024) > 1000) {
      count++
    }

    return size
    .toFixed(2)
    .replace(/\.0+$/, '') + ' ' + units[count]
  }

  $.fn.disabled = function (value) {
    return this.prop('disabled', !!value)
  }
})
(jQuery)
