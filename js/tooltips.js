/*
originally written by paul sowden <paul@idontsmoke.co.uk> | http://idontsmoke.co.uk
modified and localized by alexander shurkayev <alshur@narod.ru> | http://htmlcoder.visions.ru
*/

window.onerror = null;
var tooltip_attr_name = "tooltip";

window.onload = function(e){
if (document.createElement) tooltip.d();
}

tooltip =
{
  t: document.createElement("DIV"),
  c: null,
  g: false,

  m: function(e)
  {
    if (tooltip.g)
    {
      oCanvas = document.
          getElementsByTagName((document.compatMode &&
              document.compatMode == "CSS1Compat") ? "HTML" : "BODY")[0];

      x = window.event ? event.clientX + oCanvas.scrollLeft : e.pageX;
      y = window.event ? event.clientY + oCanvas.scrollTop : e.pageY;

      tooltip.a(x, y);
    }
  },

  d: function()
  {
//    return;
    opacity=80;
    tooltip.t.setAttribute("id", "tooltip");
    tooltip.t.style.filter = "alpha(opacity="+opacity+")"; // buggy in ie5.0
//    tooltip.t.style.background='none';
//    tooltop.t.style.KHTMLOpacity = opacity/100;
    // Older Mozilla and Firefox
  //  tooltip.t.style.MozOpacity = opacity/100;

    // Safari 1.2, newer Firefox and Mozilla, CSS3
    tooltip.t.style.opacity = opacity/100;

    document.body.appendChild(tooltip.t);
    a = document.all ? document.all : document.getElementsByTagName("*");
    aLength = a.length;
    for (var i = 0; i < aLength; i++)
    {
      if (a[i].getAttribute("title"))
      {
        a[i].setAttribute(tooltip_attr_name, a[i].getAttribute("title"));
        if (a[i].getAttribute(tooltip_attr_name)){
          a[i].removeAttribute("title");
          if (a[i].getAttribute("alt") && a[i].complete) a[i].removeAttribute("alt");
          tooltip.l(a[i], "mouseover", tooltip.s);
          tooltip.l(a[i], "mouseout", tooltip.h);
        }
      }
      else if (a[i].getAttribute("alt") && a[i].complete)
      {
        a[i].setAttribute(tooltip_attr_name, a[i].getAttribute("alt"));
        if (a[i].getAttribute(tooltip_attr_name))
        {
          a[i].removeAttribute("alt");
          tooltip.l(a[i], "mouseover", tooltip.s);
          tooltip.l(a[i], "mouseout", tooltip.h);
        }
      }
    }
    document.onmousemove = tooltip.m;
    window.onscroll = tooltip.h;
  },

  s: function(e){
    d = window.event ? window.event.srcElement : e.currentTarget;
    if (!d || !d.getAttribute(tooltip_attr_name)) return;
    if (tooltip.t.firstChild) tooltip.t.removeChild(tooltip.t.firstChild);
    tooltip.t.appendChild(document.createTextNode(d.getAttribute(tooltip_attr_name)));
    /*s = d.getAttribute(tooltip_attr_name);
    re = /  /i;
    tooltip.t.innerHTML = s.replace(re, "<br />");*/
    tooltip.c = setTimeout("tooltip.t.style.visibility = 'visible';", 1);
    tooltip.g = true;
  },

  h: function(e){
    tooltip.t.style.visibility = "hidden";
    // thanks to Alexander Shurkayev for helping me optimise this line :-)
    if (tooltip.t.firstChild)
      tooltip.t.removeChild(tooltip.t.firstChild);
    clearTimeout(tooltip.c);
    tooltip.g = false;
    tooltip.a(-99, -99);
  },

  l: function(o, e, a){
    if (o.addEventListener) o.addEventListener(e, a, false); // was true--Opera7b workaround!
    else if (o.attachEvent) o.attachEvent("on" + e, a);
      else return null;
  },

  a: function(x, y)
  {
    oCanvas = document.getElementsByTagName(
          (document.compatMode && document.compatMode == "CSS1Compat") ? "HTML" : "BODY")[0];

    w_width = window.innerWidth ? window.innerWidth + window.pageXOffset : oCanvas.clientWidth + oCanvas.scrollLeft;
    w_height = window.innerHeight ? window.innerHeight + window.pageYOffset : oCanvas.clientHeight + oCanvas.scrollTop;

    t_width = window.event ? tooltip.t.clientWidth : tooltip.t.offsetWidth;
    t_height = window.event ? tooltip.t.clientHeight : tooltip.t.offsetHeight;

    t_extra_width = 7; // CSS padding + borderWidth;
    t_extra_height = 5; // CSS padding + borderHeight;

    tooltip.t.style.left = x + 8 + "px";
    tooltip.t.style.top = y + 8 + "px";

    while (x + t_width + t_extra_width > w_width)
    {
      x -= x + t_width + t_extra_width - w_width;
      tooltip.t.style.left = x + "px";
      t_width = window.event ? tooltip.t.clientWidth : tooltip.t.offsetWidth;
    }

    while (y + t_height + t_extra_height > w_height)
    {
      y -= y + t_height + t_extra_height - w_height;
      tooltip.t.style.top = y + "px";
      t_height = window.event ? tooltip.t.clientHeight : tooltip.t.offsetHeight;
    }
  }
}
