import * as React from "react";
import {svgInfo} from "../utils/tableHeader";

export function PopoversHeader({ header, accessor, description }) {
  const popoverRef = React.useRef();

  React.useEffect(() => {
    if (popoverRef.current) {
      const popover = new coreui.Popover(popoverRef.current, {trigger: "hover", html: true});
    }
  }, [])

  let formattedDescription = ""

  if (description) {
    formattedDescription = description.replace(/\n/g, "<br>");
  }

  function SpanWithDescription() {
    return (
    <span role="button" ref={popoverRef}
      data-coreui-content={formattedDescription}
      data-coreui-original-title={header}
      data-coreui-placement="top"
      data-coreui-toggle="popover" title="">{header}
      <svg className="icon ms-1">
        <use xlinkHref={svgInfo()}></use>
      </svg>
    </span>
    );
  }

  function SpanWithoutDescription() {
    return <>{header}</>;
  }

  if (formattedDescription) {
    return SpanWithDescription();
  } else {
    return SpanWithoutDescription();
  }
}
