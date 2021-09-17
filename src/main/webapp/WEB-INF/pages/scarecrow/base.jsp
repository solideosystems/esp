<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib prefix="page" uri="esp://taglib/page" %>
<page:base title="{}">
    <header>
        <div class="app-search">
            <div class="app-button">
                <button id="기본기능_버튼" class="btn btn-primary"></button>
            </div>
        </div>
    </header>

    <main>
        <section class="app--column">
            <div>
                왼쪽
            </div>
            <div>
                <form id="수정_폼">
                    <label title="항목1">
                        <input name="item1" required>
                    </label>
                    <label title="항목2">
                        <select name="item2" data-code="FRUITS"><!-- 공통코드 FRUITS -->
                            <option>option1</option>
                            <option>option2</option>
                            <option>option3</option>
                        </select>
                    </label>
                    <label title="항목3">
                        <textarea name="item3"></textarea>
                    </label>
                    <label title="항목4">
                        <input type="checkbox" name="item4">
                    </label>

                    <div class="app-button">
                        <button type="button" data-modal="#어떤기능_팝업"
                                class="btn btn-default">어떤기능
                        </button>
                    </div>
                </form>
            </div>
        </section>

        <figure id="어떤기능_팝업" class="app--popup" title="어떤기능 하는 팝업">
            <form id="하위메뉴입력_폼">
                <label title="항목1">
                    <input name="item1" required>
                </label>
                <label title="항목2">
                    <select name="item2">
                        <option>option1</option>
                        <option>option2</option>
                        <option>option3</option>
                    </select>
                </label>
                <label title="항목3">
                    <textarea name="item3"></textarea>
                </label>

                <div class="app-button">
                    <button id="저장_버튼" type="button" class="btn btn-primary"></button>
                </div>
            </form>
        </figure>
    </main>


    <script defer title="그리드 정의"></script>

    <script defer title="이벤트 정의"></script>

    <script defer title="기능"></script>
</page:base>
