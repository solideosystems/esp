CKEDITOR.editorConfig = function (config) {
  config.toolbar = [
    // { name: 'document', items: ['Source', '-', 'Save', 'NewPage', 'ExportPdf', 'Preview', 'Print', '-', 'Templates'] },
    // { name: 'clipboard', items: ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo'] },
    // { name: 'editing', items: ['Find', 'Replace', '-', 'SelectAll', '-', 'Scayt'] },
    // { name: 'forms', items: ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'] },
    {name: 'styles', items: [/* 'Styles',  */'Format']},
    {name: 'basicstyles',
      items: ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript',
        'Superscript', '-', 'CopyFormatting', 'RemoveFormat']
    },
    {name: 'colors', items: ['TextColor', 'BGColor']},
    {name: 'paragraph',
      items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-',
        'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter',
        'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl', 'Language']
    },
    {name: 'links', items: ['Link', 'Unlink'/* , 'Anchor' */]},
    {name: 'others', items: ['VideoDetector']},
    {name: 'insert',
      items: ['Image', 'Flash', 'Table', 'HorizontalRule', 'Smiley',
        'SpecialChar', 'PageBreak', 'Iframe']
    },
    {name: 'tools', items: ['Maximize', 'ShowBlocks']},
    {name: 'about', items: ['About']}
  ]

  config.height = '30rem'

  config.extraPlugins = ['videodetector', 'colorbutton', 'uploadimage']

  config.image_previewText = ' '
  config.imageUploadUrl = '/_file/image-from-editor'
}
