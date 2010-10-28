
function GotoBack(url) {
    if (history.length>1) {
        history.back();
    } else {
        location.replace(url);
    }
}

//inserts the new content into the page
function insertNewContent(liName,liTime,liUser,liText) {
}

function sendConnect() {
	street_id = document.forms['connect'].elements['street_id'].value;
	number = document.forms['connect'].elements['number'].value;
	if ((httpSend.readyState == 4 || httpSend.readyState == 0) && number != '') {
		param = '&street_id='+ street_id +'&number='+ number;
                var tr = document.getElementById("is_connected");
                tr.style.display='';
                var price = document.getElementById("price"); price.innerHTML = 'загрузка информации..';
                var desc = document.getElementById("desc");   desc.innerHTML = '';

		httpSend.open("POST", '/geo/is_connected', true);
		httpSend.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
  	        httpSend.onreadystatechange = handlehHttpSend;
  	        httpSend.send(param);
	} else {
		setTimeout('sendComment();',1000);
	}
}

//deals with the servers' reply to sending a comment
function handlehHttpSend() {

  if (httpSend.readyState == 4) {
    results = httpSend.responseText.split('---');

    var tr = document.getElementById("is_connected");
    tr.style.display='';
    var price = document.getElementById("price");
    var desc = document.getElementById("desc");


    if (results[0]=='') {
     price.innerHTML = 'стоимость обычная или по согласованию';
     desc.innerHTML = 'НЕ ПОДКЛЮЧЕН';
    } else {
     price.innerHTML = results[0];
     price_firm.innerHTML = results[1];
     connection.innerHTML = results[2];
     var price_input = document.getElementById("price_input");
     desc.innerHTML = results[3];
//     price_input.value = results[1];
    }
  }

}


//initiates the XMLHttpRequest object
//as found here: http://www.webpasties.com/xmlHttpRequest
function getHTTPObject() {
  var xmlhttp;
  /*@cc_on
  @if (@_jscript_version >= 5)
    try {
      xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
      try {
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (E) {
        xmlhttp = false;
      }
    }
  @else
  xmlhttp = false;
  @end @*/
  if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
    try {
      xmlhttp = new XMLHttpRequest();
    } catch (e) {
      xmlhttp = false;
    }
  }
  return xmlhttp;
}


// initiates the two objects for sending and receiving data
var httpSend = getHTTPObject();

// показывать/скрывать блок
function toggleEdit (id) {
  var se = document.getElementById(id);
  if (se.style.display ) {
    se.style.display='';
  } else {
    se.style.display='none';
  }
}


/* edit select */

function hideElement (id) {
    var a = document.getElementById(id);
    a.style.display='none';
}

function showElement (id) {
    var a = document.getElementById(id);
    a.style.display='';
}


/* FORUM */

function hideCommentForm (node) {
  var a = node.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
  var exists = a.childNodes[0];
  a.removeChild(exists);
  return false;
}


function toggleCommentForm (id) {

  var templ = document.getElementById('comment_template');
  if (!id) { id=''; }
  var a = document.getElementById('a'+id);
  var exists = a.childNodes[0];
  if (exists) {
      a.removeChild(exists);
  } else {
  //  var o = document.getElementById('o'+id);
      var n = templ.cloneNode(1);
  //  a.removeChild(o);
      a.appendChild(n);
      a.getElementsByTagName('input')[0].value=id;

  }
}

function checklogin() {
    f = document.forms['LOGIN'];
    f.go.disabled = ((f.password.value == "") || (f.login.value == ""));
}

function checkmail() {
    b = document.forms['mess'];
    b.submit.disabled = ((b.talker.value == "") || (b.message.value == ""));
}

function checkcomment() {
    c = document.forms['comment'];
    c.submit.disabled = (c.text.value == "");
}

function checknew() {
    t = document.forms['newtopic'];
    t.submit.disabled = ((t.subject.value == "") || (t.text.value == "") || (t.text.value == "Ну, давай, удиви..") || (t.subject.value == "Тема статьи"));
}

function open_login() {
  var l = document.getElementById("login");
  l.style.display='';
  l = document.getElementById("in");
  l.style.display='none';
}



//Snegovik


function ctrl_enter(e, form, formtxt)
{
	if (((e.keyCode == 13) || (e.keyCode == 10)) && (e.ctrlKey == true)) {

if (formtxt.value!='') {form.submit();} }
}

function ctrl_enter2(e, form)
{
	if (((e.keyCode == 13) || (e.keyCode == 10)) && (e.ctrlKey == true)) { form.submit();}
}


function checksubm(parrametr) {
    t = document.forms[parrametr];
    if (t.text) {
      t.ok.disabled = (t.text.value == "");
      if (t.save) {
         t.save.disabled = (t.text.value == "");
      }
    }
}


function EnableSubmits(form, text) {
    var disabled = (text.value == "");
    var inputs = form.getElementsByTagName("input");
    for (i=0; i < inputs.length; i++) {
        if (inputs[i].type == 'submit') {
            inputs[i].disabled=disabled;
        }
     }
}


function DisableSubmits(form_name, text) {
    var form = document.forms[form_name];
    var inputs = form.getElementsByTagName("input");
    for (i=0; i < inputs.length; i++) {
        if (inputs[i].type == 'submit') {
            inputs[i].disabled=true;
        }
     }
}





/* RATING */

function browseViewType(viewType){
hideInline(viewType=='L'?"relatedNotList":"relatedList");
showInline(viewType=='L'?"relatedList":"relatedNotList");
hideInline(viewType=='L'?"relatedGrid":"relatedNotGrid");
showInline(viewType=='L'?"relatedNotGrid":"relatedGrid");
removeClass(_gel('video_grid'),viewType=='L'?'browseGridView':'browseListView');
addClass(_gel('video_grid'),viewType=='L'?'browseListView':'browseGridView');
createCookie('bvt',viewType,365);
return false;
}
function membersViewType(viewType){
hideInline(viewType=='L'?"relatedNotList":"relatedList");
showInline(viewType=='L'?"relatedList":"relatedNotList");
hideInline(viewType=='L'?"relatedGrid":"relatedNotGrid");
showInline(viewType=='L'?"relatedNotGrid":"relatedGrid");
removeClass(_gel('video_grid'),viewType=='L'?'membersGridView':'membersListView');
addClass(_gel('video_grid'),viewType=='L'?'membersListView':'membersGridView');
createCookie('bvt',viewType,365);
return false;
}
function getXmlHttpRequest()
{
var httpRequest=null;
try
{
httpRequest=new ActiveXObject("Msxml2.XMLHTTP");
}
catch(e)
{
try
{
httpRequest=new ActiveXObject("Microsoft.XMLHTTP");
}
catch(e)
{
httpRequest=null;
}
}
if(!httpRequest&&typeof XMLHttpRequest!="undefined")
{
httpRequest=new XMLHttpRequest();
}
return httpRequest;
}
function getUrlSync(url)
{
return getUrl(url,false,null);
}
function getUrlAsync(url,handleStateChange)
{
return getUrl(url,true,handleStateChange);
}
function getUrl(url,async,handleStateChange){
var xmlHttpReq=getXmlHttpRequest();
if(!xmlHttpReq)
return;
if(handleStateChange)
{
xmlHttpReq.onreadystatechange=function()
{
handleStateChange(xmlHttpReq);
};
}
else
{
xmlHttpReq.onreadystatechange=function(){;}
}
xmlHttpReq.open("GET",url,async);
xmlHttpReq.send(null);
}
function postUrl(url,data,async,stateChangeCallback)
{
var xmlHttpReq=getXmlHttpRequest();
if(!xmlHttpReq)
return;
xmlHttpReq.open("POST",url,async);
xmlHttpReq.onreadystatechange=function()
{
stateChangeCallback(xmlHttpReq);
};
xmlHttpReq.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
xmlHttpReq.send(data);
}
function urlEncodeDict(dict)
{
var result="";
for(var i=0;i<dict.length;i++){
result+="&"+encodeURIComponent(dict[i].name)+"="+encodeURIComponent(dict[i].value);
}
return result;
}

function execOnSuccess(stateChangeCallback,successCallback,div_id)
{
    return function(xmlHttpReq)
    {
        if(xmlHttpReq.readyState==4&&
           xmlHttpReq.status==200){
            if(div_id){
                stateChangeCallback(xmlHttpReq,successCallback,div_id);
            }else{
                stateChangeCallback(xmlHttpReq,successCallback);
            }
        }
    };
}


function postFormByForm(form,async,successCallback){
var formVars=new Array();
for(var i=0;i<form.elements.length;i++)
{
var formElement=form.elements[i];
if(formElement.type=='checkbox'&&!formElement.checked){
continue;
}
var v=new Object;
v.name=formElement.name;
v.value=formElement.value;
formVars.push(v);
}
postUrl(form.action,urlEncodeDict(formVars),async,execOnSuccess(successCallback));
}
function postForm(formName,async,successCallback)
{
var form=document.forms[formName];
return postFormByForm(form,async,successCallback);
}

function replaceDivContents(xmlHttpRequest,dstDivId)
{
var dstDiv=document.getElementById(dstDivId);
dstDiv.innerHTML=xmlHttpRequest.responseText;
}


function toggleDisplay(divName){
    var tempDiv=document.getElementById(divName);
    if(!tempDiv){
        return false;
    }
    if((tempDiv.style.display=="block")||(tempDiv.style.display==""&&tempDiv.className.indexOf("hid")==0)){
        tempDiv.style.display="none";
        return false;
    }else if((tempDiv.style.display=="none")||(tempDiv.className.indexOf("hid")!=0)){
        tempDiv.style.display="block";
        return true;
    }
}
function toggleDisplay2(){
    var elements=Array.prototype.slice.call(arguments);
    arrayEach(elements,function(arg){
                  var element=ref(arg);
                  if(element){
                      element.style.display=(element.style.display!="none"?"none":"");
                  }
              });
}
function setVisible(divName,onOrOff){
    var tempDiv=document.getElementById(divName);
    if(!tempDiv){
        return;
    }
    if(onOrOff){
        tempDiv.style.visibility="visible";
    }else{
        tempDiv.style.visibility="hidden";
    }
}
function hasClass(element,_className){
    if(!element){
        return;
    }
    var upperClass=_className.toUpperCase();
    if(element.className){
        var classes=element.className.split(' ');
        for(var i=0;i<classes.length;i++){
            if(classes[i].toUpperCase()==upperClass){
                return true;
            }
        }
    }
    return false;
}


function addClass(element,_class){
    if(!hasClass(element,_class)){
        element.className+=element.className?(" "+_class):_class;
    }
}
function getClassList(element){
    if(element.className){
        return element.className.split(' ');
    }else{
        return[];
    }
}
function removeClass(element,_class){
    var upperClass=_class.toUpperCase();
    var remainingClasses=[];
    if(element.className){
        var classes=element.className.split(' ');
        for(var i=0;i<classes.length;i++){
            if(classes[i].toUpperCase()!=upperClass){
                remainingClasses[remainingClasses.length]=classes[i];
            }
        }
        element.className=remainingClasses.join(' ');
    }
}
function toggleClass(element,className){
    var el=ref(element);
    if(el){
        if(hasClass(el,className)){
            removeClass(el,className);
        }else{
            addClass(el,className);
        }
    }
}

onLoadFunctionList=new Array();
function performOnLoadFunctions()
{
    for(var i=0;i<onLoadFunctionList.length;i++)
    {
        onLoadFunctionList[i]();
    }
}
var UT_RATING_IMG='icn_star_full';
var UT_RATING_IMG_BLINK='icn_star_blink';
var UT_RATING_IMG_HALF='icn_star_half';
var UT_RATING_IMG_BG='icn_star_empty';
function UTRating(ratingElementId,maxStars,objectName,formName,ratingMessageId,componentSuffix,messages,starCount,callback)
{
    this.ratingElementId=ratingElementId;
    this.maxStars=maxStars;
    this.objectName=objectName;
    this.formName=formName;
    this.ratingMessageId=ratingMessageId;
    this.componentSuffix=componentSuffix;
    this.messages=messages;
    this.callback=callback;
    this.starTimer=null;
    this.starCount=0;
    if(starCount){
        this.starCount=starCount;
        that=this;
        onLoadFunctionList.push(function(){that.drawStars(that.starCount,true);});
    }
    function showStars(starNum,skipMessageUpdate){
        this.clearStarTimer();
        this.greyStars();
        this.colorStars(starNum);
        if(!skipMessageUpdate)
            this.setMessage(starNum,messages);
    }
    function setMessage(starNum){
        if(starNum>0){
            if(!this.savedMessage){
                this.savedMessage=document.getElementById(this.ratingMessageId).innerHTML;
            }
            document.getElementById(this.ratingMessageId).innerHTML=this.messages[starNum-1];
        }else if(this.savedMessage){
            document.getElementById(this.ratingMessageId).innerHTML=this.savedMessage;
        }
    }
    function colorStars(starNum){
        for(var i=0;i<starNum;i++){
            removeClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG_HALF);
            removeClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG_BG);
            addClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG);
        }
    }
    function greyStars(){
        for(var i=0;i<this.maxStars;i++)
            if(i<=this.starCount){
                removeClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG);
                removeClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG_HALF);
                addClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG_BG);
            }
            else
            {
                removeClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG);
                removeClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG_HALF);
                addClass(document.getElementById('star_'+this.componentSuffix+"_"+(i+1)),UT_RATING_IMG_BG);
            }
    }
    function setStars(starNum){
        this.starCount=starNum;
        this.drawStars(starNum);
        document.forms[this.formName]['rating'].value=this.starCount;
        var ratingElementId=this.ratingElementId;
        that=this;
        
        var dstDiv=document.getElementById(ratingElementId);
        dstDiv.innerHTML="Подождите, идет учет вашего голоса.."; 
        postForm(this.formName,true,function(req){
                     replaceDivContents(req,ratingElementId);
                     if(that.callback){
                         that.callback();
                     }
                 });
    }
    function drawStars(starNum,skipMessageUpdate){
        this.starCount=starNum;
        this.showStars(starNum,skipMessageUpdate);
    }
    function clearStars(){
        this.starTimer=setTimeout(this.objectName+".resetStars()",300);
    }
    function resetStars(){
        this.clearStarTimer();
        if(this.starCount)
            this.drawStars(this.starCount);
        else
            this.greyStars();
        this.setMessage(0);
    }
    function clearStarTimer(){
        if(this.starTimer){
            clearTimeout(this.starTimer);
            this.starTimer=null;
        }
    }
    
    this.clearStars=clearStars;
    this.clearStarTimer=clearStarTimer;
    this.greyStars=greyStars;
    this.colorStars=colorStars;
    this.resetStars=resetStars;
    this.setStars=setStars;
    this.drawStars=drawStars;
    this.showStars=showStars;
    this.setMessage=setMessage;
}

ratingHoverTimers=[];
function ratingHoverOver(componentSuffix){
    if(componentSuffix==""){
        componentSuffix=="reserved"
            }
    _clearHoverTimer(componentSuffix);
    hideDiv('defaultRatingMessage'+componentSuffix);
    showDiv('hoverMessage'+componentSuffix);
}
function ratingHoverOut(componentSuffix){
if(componentSuffix==""){
componentSuffix=="reserved"
}
ratingHoverTimers[componentSuffix]=setTimeout(function(){_ratingHoverClear(componentSuffix);},300);
}
function _ratingHoverClear(componentSuffix){
if(componentSuffix==""){
componentSuffix=="reserved"
}
_clearHoverTimer();
hideDiv('hoverMessage');
showDiv('defaultRatingMessage');
}
function _clearHoverTimer(componentSuffix){
if(componentSuffix==""){
componentSuffix=="reserved"
}
if(ratingHoverTimers[componentSuffix]){
clearTimeout(ratingHoverTimers[componentSuffix]);
ratingHoverTimers[componentSuffix]=null;
}
}




