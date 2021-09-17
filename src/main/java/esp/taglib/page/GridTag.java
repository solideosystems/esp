package esp.taglib.page;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class GridTag extends BaseTag {

  private static final long serialVersionUID = -6368428259652138861L;


  @Override
  public String header(String html) {
    return super.header(html)
        + script("/js/ag-grid.min.js")
        + script("/js/ag-grid.support.js")
        + css("/css/ag-grid.css")
        + css("/css/ag-theme-alpine.css");
  }

}
