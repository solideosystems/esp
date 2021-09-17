package esp.taglib.page;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ArticleTag extends BaseTag {

  private static final long serialVersionUID = 3923521252717625628L;


  @Override
  public String header(String html) {
    return super.header(html)
        + script("/js/ag-grid.min.js")
        + script("/js/ag-grid.support.js")
        + script("/js/ckeditor/ckeditor.js")
        + script("/js/ckeditor/config.js")
        + css("/css/ag-grid.css")
        + css("/css/ag-theme-alpine.css");
  }

}
