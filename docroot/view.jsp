<%@ include file="/init.jsp" %>

<%
String title = LocalizationUtil.getPreferencesValue(portletPreferences, "title", themeDisplay.getLanguageId());
String description = LocalizationUtil.getPreferencesValue(portletPreferences, "description", themeDisplay.getLanguageId());
boolean requireCaptcha = GetterUtil.getBoolean(portletPreferences.getValue("requireCaptcha", StringPool.BLANK));
String successURL = portletPreferences.getValue("successURL", StringPool.BLANK);
boolean saveToDatabase = GetterUtil.getBoolean(portletPreferences.getValue("saveToDatabase", StringPool.BLANK));
boolean showPreviousPosts = GetterUtil.getBoolean(portletPreferences.getValue("showPreviousPosts", StringPool.BLANK));
String databaseTableName = portletPreferences.getValue("databaseTableName", StringPool.BLANK);
%>

<portlet:actionURL var="saveDataURL">
	<portlet:param name="<%= ActionRequest.ACTION_NAME %>" value="saveData" />
</portlet:actionURL>

<aui:form action="<%= saveDataURL %>" enctype="multipart/form-data" method="post" name="fm">
	<c:if test="<%= Validator.isNull(successURL) %>">
		<aui:input name="redirect" type="hidden" value="<%= currentURL %>" />
	</c:if>

	<aui:fieldset label="<%= HtmlUtil.escape(title) %>">
		<c:if test="<%= Validator.isNotNull(description) %>">
			<p class="description"><%= HtmlUtil.escape(description) %></p>
		</c:if>

		<liferay-ui:success key="success" message="the-form-information-was-sent-successfully" />

		<liferay-ui:error exception="<%= CaptchaMaxChallengesException.class %>" message="maximum-number-of-captcha-attempts-exceeded" />
		<liferay-ui:error exception="<%= CaptchaTextException.class %>" message="text-verification-failed" />
		<liferay-ui:error key="error" message="an-error-occurred-while-sending-the-form-information" />

		<c:if test='<%= PortletPropsValues.VALIDATION_SCRIPT_ENABLED && SessionErrors.contains(renderRequest, "validationScriptError") %>'>
			<liferay-util:include page="/script_error.jsp" />
		</c:if>

		<%
		int i = 1;

		String fieldName = "field" + i;
		String fieldLabel = LocalizationUtil.getPreferencesValue(portletPreferences, "fieldLabel" + i, themeDisplay.getLanguageId());
		boolean fieldOptional = PrefsParamUtil.getBoolean(portletPreferences, request, "fieldOptional" + i, false);
		String fieldValue = ParamUtil.getString(request, fieldName);

		while ((i == 1) || Validator.isNotNull(fieldLabel)) {
			String fieldType = portletPreferences.getValue("fieldType" + i, "text");
			String fieldOptions = LocalizationUtil.getPreferencesValue(portletPreferences, "fieldOptions" + i, themeDisplay.getLanguageId());
			String fieldValidationScript = portletPreferences.getValue("fieldValidationScript" + i, StringPool.BLANK);
			String fieldValidationErrorMessage = portletPreferences.getValue("fieldValidationErrorMessage" + i, StringPool.BLANK);
		%>

			<c:if test="<%= PortletPropsValues.VALIDATION_SCRIPT_ENABLED %>">
				<liferay-ui:error key='<%= "error" + fieldLabel %>' message="<%= fieldValidationErrorMessage %>" />

				<c:if test="<%= Validator.isNotNull(fieldValidationScript) %>">
					<div class="hide" id="<portlet:namespace />validationError<%= fieldName %>">
						<span class="alert alert-error"><%= fieldValidationErrorMessage %></span>
					</div>
				</c:if>
			</c:if>

			<c:if test="<%= !fieldOptional %>">
				<div class="hide" id="<portlet:namespace />fieldOptionalError<%= fieldName %>">
					<span class="alert alert-error"><liferay-ui:message key="this-field-is-mandatory" /></span>
				</div>
			</c:if>

			<c:choose>
				<c:when test='<%= fieldType.equals("paragraph") %>'>
					<p class="lfr-webform" id="<portlet:namespace /><%= fieldName %>"><%= HtmlUtil.escape(fieldOptions) %></p>
				</c:when>
				<c:when test='<%= fieldType.equals("text") %>'>
					<aui:input cssClass='<%= fieldOptional ? "optional" : StringPool.BLANK %>' label="<%= HtmlUtil.escape(fieldLabel) %>" name="<%= fieldName %>" value="<%= HtmlUtil.escape(fieldValue) %>" />
				</c:when>
				<c:when test='<%= fieldType.equals("textarea") %>'>
					<aui:input cssClass='<%= "lfr-textarea-container" + (fieldOptional ? "optional" : StringPool.BLANK) %>' label="<%= HtmlUtil.escape(fieldLabel) %>" name="<%= fieldName %>" type="textarea" value="<%= HtmlUtil.escape(fieldValue) %>" wrap="soft" />
				</c:when>
				<c:when test='<%= fieldType.equals("file") %>'>
					<aui:input cssClass='<%= fieldOptional ? "optional" : StringPool.BLANK %>' label="<%= HtmlUtil.escape(fieldLabel) %>" name="<%= fieldName %>" type="file" value="<%=HtmlUtil.escape(fieldValue) %>"/>
				</c:when>
				<c:when test='<%= fieldType.equals("checkbox") %>'>
					<aui:input cssClass='<%= fieldOptional ? "optional" : StringPool.BLANK %>' label="<%= HtmlUtil.escape(fieldLabel) %>" name="<%= fieldName %>" type="checkbox" value="<%= GetterUtil.getBoolean(fieldValue) %>" />
				</c:when>
				<c:when test='<%= fieldType.equals("radio") %>'>
					<aui:field-wrapper cssClass='<%= fieldOptional ? "optional" : StringPool.BLANK %>' label="<%= HtmlUtil.escape(fieldLabel) %>" name="<%= fieldName %>">

						<%
						for (String fieldOptionValue : WebFormUtil.split(fieldOptions)) {
						%>

							<aui:input checked="<%= fieldValue.equals(fieldOptionValue) %>" label="<%= HtmlUtil.escape(fieldOptionValue) %>" name="<%= fieldName %>" type="radio" value="<%= HtmlUtil.escape(fieldOptionValue) %>" />

						<%
						}
						%>

					</aui:field-wrapper>
				</c:when>
				<c:when test='<%= fieldType.equals("options") %>'>
					<aui:select cssClass='<%= fieldOptional ? "optional" : StringPool.BLANK %>' label="<%= HtmlUtil.escape(fieldLabel) %>" name="<%= fieldName %>">

						<%
						for (String fieldOptionValue : WebFormUtil.split(fieldOptions)) {
						%>

							<aui:option selected="<%= fieldValue.equals(fieldOptionValue) %>" value="<%= HtmlUtil.escape(fieldOptionValue) %>"><%= HtmlUtil.escape(fieldOptionValue) %></aui:option>

						<%
						}
						%>

					</aui:select>
				</c:when>
			</c:choose>

		<%
			i++;

			fieldName = "field" + i;
			fieldLabel = LocalizationUtil.getPreferencesValue(portletPreferences, "fieldLabel" + i, themeDisplay.getLanguageId());
			fieldOptional = PrefsParamUtil.getBoolean(portletPreferences, request, "fieldOptional" + i, false);
			fieldValue = ParamUtil.getString(request, fieldName);
		}
		%>

		<c:if test="<%= requireCaptcha %>">
			<portlet:resourceURL var="captchaURL">
				<portlet:param name="<%= Constants.CMD %>" value="captcha" />
			</portlet:resourceURL>

			<liferay-ui:captcha url="<%= captchaURL %>" />
		</c:if>

		<aui:button onClick="" type="submit" value="send" />
	</aui:fieldset>
</aui:form>

<aui:script use="aui-base,selector-css3">
	var form = A.one('#<portlet:namespace />fm');

	if (form) {
		form.on(
			'submit',
			function(event) {
				var keys = [];

				var fieldLabels = {};
				var fieldOptional = {};
				var fieldValidationErrorMessages = {};
				var fieldValidationFunctions = {};
				var fieldsMap = {};

				<%
				int i = 1;

				String fieldName = "field" + i;
				String fieldLabel = portletPreferences.getValue("fieldLabel" + i, StringPool.BLANK);

				while ((i == 1) || Validator.isNotNull(fieldLabel)) {
					boolean fieldOptional = PrefsParamUtil.getBoolean(portletPreferences, request, "fieldOptional" + i, false);
					String fieldType = portletPreferences.getValue("fieldType" + i, "text");
					String fieldValidationScript = portletPreferences.getValue("fieldValidationScript" + i, StringPool.BLANK);
					String fieldValidationErrorMessage = portletPreferences.getValue("fieldValidationErrorMessage" + i, StringPool.BLANK);
				%>

					var key = '<%= fieldName %>';

					keys[<%= i %>] = key;

					fieldLabels[key] = '<%= HtmlUtil.escape(fieldLabel) %>';
					fieldValidationErrorMessages[key] = '<%= fieldValidationErrorMessage %>';

					function fieldValidationFunction<%= i %>(currentFieldValue, fieldsMap) {
						<c:choose>
							<c:when test="<%= PortletPropsValues.VALIDATION_SCRIPT_ENABLED && Validator.isNotNull(fieldValidationScript) %>">
								<%= fieldValidationScript %>
							</c:when>
							<c:otherwise>
								return true;
							</c:otherwise>
						</c:choose>
					};

					fieldOptional[key] = <%= fieldOptional %>;
					fieldValidationFunctions[key] = fieldValidationFunction<%= i %>;

					<c:choose>
						<c:when test='<%= fieldType.equals("radio") %>'>
							var radioButton = A.one('input[name=<portlet:namespace />field<%= i %>]:checked');

							fieldsMap[key] = '';

							if (radioButton) {
								fieldsMap[key] = radioButton.val();
							}
						</c:when>
						<c:otherwise>
							var inputField = A.one('#<portlet:namespace />field<%= i %>');

							fieldsMap[key] = (inputField && inputField.val()) || '';
						</c:otherwise>
					</c:choose>

				<%
					i++;

					fieldName = "field" + i;
					fieldLabel = portletPreferences.getValue("fieldLabel" + i, "");
				}
				%>

				var validationErrors = false;

				for (var i = 1; i < keys.length; i++) {
					var key = keys [i];

					var currentFieldValue = fieldsMap[key];

					var optionalFieldError = A.one('#<portlet:namespace />fieldOptionalError' + key);
					var validationError = A.one('#<portlet:namespace />validationError' + key);

					if (!fieldOptional[key] && currentFieldValue.match(/^\s*$/)) {
						validationErrors = true;

						A.all('.alert-success').hide();

						if (optionalFieldError) {
							optionalFieldError.show();
						}
					}
					else if (!fieldValidationFunctions[key](currentFieldValue, fieldsMap)) {
						validationErrors = true;

						A.all('.alert-success').hide();

						if (optionalFieldError) {
							optionalFieldError.hide();
						}

						if (validationError) {
							validationError.show();
						}
					}
					else {
						if (optionalFieldError) {
							optionalFieldError.hide();
						}

						if (validationError) {
							validationError.hide();
						}
					}
				}

				if (validationErrors) {
					event.halt();
					event.stopImmediatePropagation();
				}
			}
		);
	}
</aui:script>

<%
if (saveToDatabase && themeDisplay.isSignedIn() && showPreviousPosts) {
	String attrValue =user.getEmailAddress();
	
	String attributeName ="email-from";
	
	String tableName = databaseTableName;
	 
	long classNameId =ClassNameLocalServiceUtil.getClassNameId(WebFormUtil.class);
	 
	
	List<ExpandoValue> expandoValues =ExpandoValueLocalServiceUtil.getColumnValues(company.getCompanyId(), classNameId, tableName, attributeName, attrValue, -1,-1);
	
	if (expandoValues.size() > 0) {
		List<String> columnNames = new ArrayList<String>();
	//List<ExpandoColumn> expandoColumns = ExpandoColumnLocalServiceUtil.getColumns(company.getCompanyId(), classNameId, tableName);
	//for (ExpandoColumn column:expandoColumns) {
	//	String columnName = column.getName();
	//	columnNames.add(columnName);
	//}
	
%>
	<table class="table table-bordered table-hover table-striped">
	<thead class="table-columns">
	<tr>
<%
		int i = 1;
	
		String fieldLabel = LocalizationUtil.getPreferencesValue(portletPreferences, "fieldLabel" + i, themeDisplay.getLanguageId());
	
		while ((i == 1) || Validator.isNotNull(fieldLabel)) {
			columnNames.add(fieldLabel);
			i++;
	
%>
			<th><%= fieldLabel%></th>
<%
			fieldLabel = portletPreferences.getValue("fieldLabel" + i, "");
		}
%>
		</tr>
		</thead>
		<tbody class="table-data">
<%
		String valore ="";
		for(ExpandoValue expandoValue:expandoValues) {
	 
	    	long formId = expandoValue.getClassPK();
	      	Map<String,Serializable> dati = ExpandoValueLocalServiceUtil.getData(company.getCompanyId(), WebFormUtil.class.getName(), tableName, columnNames, formId);
%>
	 
			<tr>
	
<%
			for(String columnName:columnNames) {
				valore = MapUtil.getString(dati, columnName);
%>
				<td  class="table-cell"><%= valore%></td>
<%
			} // for(String
	
%>
			</tr>
<% 
		} // for(Expando
%>
		</tbody>
	</table>
	
<% 
	} // if (expandoValues.size() > 0)
}// if (saveToDatabase)
%>