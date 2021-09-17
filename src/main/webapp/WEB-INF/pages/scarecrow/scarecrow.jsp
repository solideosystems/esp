<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=utf-8" %>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>ESP Source Generator</title>
    <style>
      * {
        box-sizing: border-box;
      }

      form {
        margin: 0 auto;
        width: 1024px;
      }

      .container {
        display: flex;
        justify-content: space-between;
        width: 100%;
      }

      .container > section {
        background-color: #000;
        color: #FFF;
        flex: 0 0 49%;
        padding: 16px;
      }

      h3 {
        margin: 2rem 0 0;
      }

      table {
        border-collapse: collapse;
        margin: 8px 0;
        width: 100%
      }

      caption,
      .template {
        display: none;
      }

      th, td {
        border: 1px solid #CCC;
        padding: 4px;
      }

      td:first-child {
        text-align: center;
      }

      td:last-child {
        text-align: right;
      }

      button {
        float: right;
        line-height: 2rem
      }

      select,
      input[type=text] {
        height: 2rem;
        width: 100%;
      }
    </style>
</head>
<body>
<form>
    <button>생성하기</button>
    <h1>ESP Source Generator</h1>

    <div class="container">
        <section>
            <h3>프로그램 이름</h3>
            <label><input name="name" type="text" required placeholder="이름을 적어주세요."></label>
            <h3>프로그램 ID</h3>
            <label><input name="id" type="text" required placeholder="camelCase 로 입력하세요."></label>

            <h3>화면유형</h3>
            <label><input value="base" name="pageType" type="radio"> 기본</label>
            <label><input value="board" name="pageType" type="radio"> 게시판</label>
            <label><input value="grid" name="pageType" type="radio" checked> 그리드</label>

            <h3>카테고리</h3>
            <dl>
                <dt>분류 1</dt>
                <dd><select id="depth1">
                    <option>animal</option>
                    <option>fruit</option>
                    <option>job</option>
                </select></dd>
                <dt>분류 2</dt>
                <dd><select id="depth2">
                    <optgroup label="animal">
                        <option>cat</option>
                        <option>dog</option>
                        <option>tiger</option>
                    </optgroup>
                    <optgroup label="fruit">
                        <option>apple</option>
                        <option>orange</option>
                        <option>melon</option>
                    </optgroup>
                    <optgroup label="job">
                        <option>teacher</option>
                        <option>student</option>
                        <option>officer</option>
                        <option>developer</option>
                    </optgroup>
                </select></dd>
            </dl>
        </section>
        <section>
            <h3>데이터베이스</h3>
            <label><input name="tableName" type="text" placeholder="테이블 이름"></label>
            <table>
                <caption>테이블 스키마</caption>
                <colgroup>
                    <col style="text-align: center">
                    <col>
                    <col>
                    <col>
                    <col style="text-align: right">
                </colgroup>
                <thead>
                <tr>
                    <th scope="col">PK</th>
                    <th scope="col">컬럼</th>
                    <th scope="col">컬럼명</th>
                    <th scope="col">타입</th>
                    <th scope="col">길이</th>
                </tr>
                </thead>
                <tbody>
                <tr class="template">
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                </tbody>
            </table>
        </section>
    </div>
</form>

<script src="<c:url value="/js/jquery-3.6.0.min.js"/>"></script>
<script src="<c:url value="/js/jquery.support.js"/>"></script>
<script defer>
  $('form').submit(function (e) {
    e.preventDefault()

    if (!/^[a-zA-Z0-9_]+$/.test($('[name=id]').val())) {
      alert('프로그램 ID는 camelCase로 작성해 주세요. (영문, 숫자, _ 만 사용 가능)')
      return false
    }

    if (!tableSelected) {
      alert('테이블을 검색한 후 진행 해 주세요.')
      return false
    }

    $.ajax({
      url: '/scarecrow/generate',
      data: $(this).serialize()
          + '&path='
          + $('select').map((i, el) => el.value).toArray().join('.')
    })
    .done(res => {
      res && alert('생성 완료 되었습니다.')
    })
  })

  var tableSelected = false
  $('[name=tableName]').keyup(function () {
    var timer = null,
        value = ''
    return function (e) {
      clearTimeout(timer)
      timer = setTimeout(() => {

        if (e.target.value !== value) {
          value = e.target.value

          $.ajax('/scarecrow/generate/table-info?tableName=' + value.toUpperCase())
          .done(res => {
            var tbody = $('tbody')
            $('tr:not(.template)', tbody).remove()

            $.each(res, (i, column) => {
              var tpl = $('.template', tbody).clone().removeClass('template');
              $('td:eq(0)', tpl).text(column.pk ? 'Y' : '')
              $('td:eq(1)', tpl).text(column.name)
              $('td:eq(2)', tpl).text(column.remark)
              $('td:eq(3)', tpl).text(column.type)
              $('td:eq(4)', tpl).text(column.size);
              tbody.append(tpl)
            })

            tableSelected = !!(res && res.length)
          })
        }
      }, 400);
    }
  }())
</script>
</body>
</html>
