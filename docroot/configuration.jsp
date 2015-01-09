<%@ include file="/init.jsp" %>

<%
String titleXml = LocalizationUtil.getLocalizationXmlFromPreferences(portletPreferences, renderRequest, "title");
String descriptionXml = LocalizationUtil.getLocalizationXmlFromPreferences(portletPreferences, renderRequest, "description");
boolean requireCaptcha = GetterUtil.getBoolean(portletPreferences.getValue("requireCaptcha", StringPool.BLANK));
String successURL = portletPreferences.getValue("successURL", StringPool.BLANK);

boolean sendAsEmail = GetterUtil.getBoolean(portletPreferences.getValue("sendAsEmail", StringPool.BLANK));
String emailFromName = WebFormUtil.getEmailFromName(portletPreferences, company.getCompanyId());
String emailFromAddress = WebFormUtil.getEmailFromAddress(portletPreferences, company.getCompanyId());
String emailAddress = portletPreferences.getValue("emailAddress", StringPool.BLANK);
String subject = portletPreferences.getValue("subject", StringPool.BLANK);
boolean sendThanksEmail = GetterUtil.getBoolean(portletPreferences.getValue("sendThanksEmail", StringPool.BLANK));
String thanksSubject = portletPreferences.getValue("thanksSubject", StringPool.BLANK);
String thanksBody = portletPreferences.getValue("thanksBody", StringPool.BLANK);


boolean saveToDatabase = GetterUtil.getBoolean(portletPreferences.getValue("saveToDatabase", StringPool.BLANK));
boolean showPreviousPosts = GetterUtil.getBoolean(portletPreferences.getValue("showPreviousPosts", StringPool.BLANK));

String databaseTableName = portletPreferences.getValue("databaseTableName", StringPool.BLANK);

boolean saveToFile = GetterUtil.getBoolean(portletPreferences.getValue("saveToFile", StringPool.BLANK));
String fileName = portletPreferences.getValue("fileName", StringPool.BLANK);

boolean uploadToDM = GetterUtil.getBoolean(portletPreferences.getValue("uploadToDM",StringPool.BLANK));
boolean uploadToDisk = GetterUtil.getBoolean(portletPreferences.getValue("uploadToDisk",StringPool.BLANK));
String uploadDiskDir =portletPreferences.getValue("uploadDiskDir",StringPool.BLANK);

boolean fieldsEditingDisabled = false;

if (WebFormUtil.getTableRowsCount(company.getCompanyId(), databaseTableName) > 0) {
	fieldsEditingDisabled = true;
}
long newFolderId = GetterUtil.getLong(portletPreferences.getValue("newFolderId",StringPool.BLANK));

String folderName = StringPool.BLANK;

if (newFolderId > 0) {
	Folder folder = DLAppLocalServiceUtil.getFolder(newFolderId);

	folder = folder.toEscapedModel();

	folderName = folder.getName();
}
else {
	folderName = LanguageUtil.get(pageContext, "home");
}

%>

<liferay-portlet:actionURL portletConfiguration="true" var="configurationActionURL" />

<liferay-portlet:renderURL portletConfiguration="true" var="configurationRenderURL" />

<aui:form action="<%= configurationActionURL %>" method="post" name="fm">
	<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />
	<aui:input name="redirect" type="hidden" value="<%= configurationRenderURL %>" />

	<liferay-ui:error exception="<%= DuplicateColumnNameException.class %>" message="please-enter-unique-field-names" />

	<liferay-ui:panel-container extended="<%= Boolean.TRUE %>" id="webFormConfiguration" persistState="<%= true %>">
		<liferay-ui:panel collapsible="<%= true %>" extended="<%= true %>" id="webFormGeneral" persistState="<%= true %>" title="form-information">
			<aui:fieldset>
				<aui:field-wrapper cssClass="lfr-input-text-container" label="title">
					<liferay-ui:input-localized name="title" xml="<%= titleXml %>" />
				</aui:field-wrapper>

				<aui:field-wrapper cssClass="lfr-textarea-container" label="description">
					<liferay-ui:input-localized name="description" type="textarea" xml="<%= descriptionXml %>" />
				</aui:field-wrapper>

				<aui:input name="preferences--requireCaptcha--" type="checkbox" value="<%= requireCaptcha %>" />

				<aui:input cssClass="lfr-input-text-container" label="redirect-url-on-success" name="preferences--successURL--" value="<%= HtmlUtil.toInputSafe(successURL) %>" />
			</aui:fieldset>
		</liferay-ui:panel>
		<liferay-ui:panel collapsible="<%= true %>" extended="<%= true %>" id="webFormData" persistState="<%= true %>" title="handling-of-form-data">
			<aui:fieldset cssClass="handle-data" label="email">
				<liferay-ui:error key="emailAddressInvalid" message="please-enter-a-valid-email-address" />
				<liferay-ui:error key="emailAddressRequired" message="please-enter-an-email-address" />
				<liferay-ui:error key="fileNameInvalid" message="please-enter-a-valid-path-and-file-name" />
				<liferay-ui:error key="handlingRequired" message="please-select-an-action-for-the-handling-of-form-data" />
				<liferay-ui:error key="subjectRequired" message="please-enter-a-subject" />
				<liferay-ui:error key="tahnksSubjectRequired" message="please-enter-a-thnaks-subject" />

				<aui:input label="send-as-email" name="preferences--sendAsEmail--" type="checkbox" value="<%= sendAsEmail %>" />

				<aui:fieldset>
					<aui:input cssClass="lfr-input-text-container" label="name-from" name="preferences--emailFromName--" value="<%= emailFromName %>" />

					<aui:input cssClass="lfr-input-text-container" label="address-from" name="preferences--emailFromAddress--" value="<%= emailFromAddress %>" />
				</aui:fieldset>

				<aui:input cssClass="lfr-input-text-container" helpMessage="add-email-addresses-separated-by-commas" label="addresses-to" name="preferences--emailAddress--" value="<%= emailAddress %>" />

				<aui:input cssClass="lfr-input-text-container" name="preferences--subject--" value="<%= subject %>" />

				<aui:input label="send-thanks-email" name="preferences--sendThanksEmail--" type="checkbox" value="<%= sendThanksEmail %>" />
				<aui:input cssClass="lfr-input-text-container" label="thanks-subject" name="preferences--thanks-subject--" value="<%= thanksSubject %>" />

				<aui:input label="thanks-body" cssClass="lfr-textarea-container" name="preferences--thanks-body--" type="textarea" value="<%= thanksBody %>" />


			</aui:fieldset>

			<aui:fieldset cssClass="handle-data" label="database">
				<liferay-ui:error key="noPreviousPosts" message="previous-posts-cannot-be-displayed" />
				<aui:input name="preferences--saveToDatabase--" type="checkbox" 
					value="<%= saveToDatabase %>" 
					helpMessage="if-this-is-checked-then-the-signedin-users-can-view-the-table-of-previous-posts"/>
				<aui:input label="show-previous-post" name="preferences--showPreviousPosts--" type="checkbox" 
					value="<%= showPreviousPosts %>" />

			</aui:fieldset>

			<aui:fieldset cssClass="handle-data" label="file">
				<aui:input name="preferences--saveToFile--" type="checkbox" value="<%= saveToFile %>" />

				<aui:input cssClass="lfr-input-text-container" label="path-and-file-name" name="preferences--fileName--" value="<%= fileName %>" />
			</aui:fieldset>
		</liferay-ui:panel>

		<liferay-ui:panel collapsible="<%= true %>" extended="<%= true %>" id="webFormFileUpload" persistState="<%= true %>" title="handling-of-file-upload">
			<aui:fieldset cssClass="handle-data" label="file-upload">
				<liferay-ui:error key="uploadMethodUndefined" message="please-define-and-configure-a-file-upload-method" />
				<liferay-ui:error key="pathNameInvalid" message="please-enter-a-valid-path-for-file-upload" />
				<c:if test="<%= fieldsEditingDisabled %>">
					<div class="alert">
						<liferay-ui:message key="there-is-existing-form-data-please-export-and-delete-it-before-making-changes-to-the-upload-file-method" />
					</div>
				</c:if>
					<aui:field-wrapper label="file-system">					
						<aui:input label="uploadToDisk" type="checkbox" name="uploadToDisk" checked="<%= uploadToDisk %>" helpMessage="please-use-an-absolute-path-on-server-with-the-right-file-system-permissions" disabled="<%= fieldsEditingDisabled %>"/>
						<aui:input cssClass="lfr-input-text-container" label="uploadDiskDir" name="preferences--uploadDiskDir--" value="<%= uploadDiskDir %>" disabled="<%= fieldsEditingDisabled %>"/>
					</aui:field-wrapper>
					
					<aui:field-wrapper label="documents-and-media">
						<aui:input label="uploadToDM" type="checkbox" name="uploadToDM" checked="<%= uploadToDM %>" helpMessage="please-use-a-folder-in-documents-and-media-with-the-right-file-system-permissions" disabled="<%= fieldsEditingDisabled %>"/>					
						<aui:field-wrapper label="select-folder">
							<div class="input-append">
								<liferay-ui:input-resource id="folderName" url="<%= folderName %>" />
								<aui:button name="selectFolderButton" id="selectFolderButton" value="select" disabled="<%= fieldsEditingDisabled %>"/>
							</div>
						</aui:field-wrapper>
						<aui:input name="newFolderId" type="hidden" value="<%= newFolderId %>" />
					</aui:field-wrapper>
			</aui:fieldset>
		</liferay-ui:panel>

		<liferay-ui:panel collapsible="<%= true %>" extended="<%= true %>" id="webFormFields" persistState="<%= true %>" title="form-fields">
			<aui:fieldset cssClass="rows-container webFields">
				<c:if test="<%= fieldsEditingDisabled %>">
					<div class="alert">
						<liferay-ui:message key="there-is-existing-form-data-please-export-and-delete-it-before-making-changes-to-the-fields" />
					</div>

					<c:if test="<%= layoutTypePortlet.hasPortletId(portletResource) %>">
						<liferay-portlet:resourceURL portletName="<%= portletResource %>" var="exportURL">
							<portlet:param name="<%= Constants.CMD %>" value="export" />
						</liferay-portlet:resourceURL>

						<%
						String taglibExport = "submitForm(document.hrefFm, '" + exportURL + "', false);";
						%>

						<aui:button onClick="<%= taglibExport %>" value="export-data" />

						<liferay-portlet:actionURL portletName="<%= portletResource %>" var="deleteURL">
							<portlet:param name="<%= ActionRequest.ACTION_NAME %>" value="deleteData" />
							<portlet:param name="redirect" value="<%= currentURL %>" />
						</liferay-portlet:actionURL>

						<%
						String taglibDelete = "submitForm(document." + renderResponse.getNamespace() + "fm, '" + deleteURL + "');";
						%>

						<aui:button onClick="<%= taglibDelete %>" value="delete-data" />
					</c:if>

					<br /><br />
				</c:if>

				<aui:input name="updateFields" type="hidden" value="<%= !fieldsEditingDisabled %>" />

				<%
				String formFieldsIndexesParam = ParamUtil.getString(renderRequest, "formFieldsIndexes") ;

				int[] formFieldsIndexes = null;

				if (Validator.isNotNull(formFieldsIndexesParam)) {
					formFieldsIndexes = StringUtil.split(formFieldsIndexesParam, 0);
				}
				else {
					formFieldsIndexes = new int[0];

					for (int i = 1; true; i++) {
						String fieldLabel = PrefsParamUtil.getString(portletPreferences, request, "fieldLabel" + i);

						if("email-from".equals(fieldLabel)){
							continue;
						}

						if (Validator.isNull(fieldLabel)) {
							break;
						}

						formFieldsIndexes = ArrayUtil.append(formFieldsIndexes, i);
					}

					if (formFieldsIndexes.length == 0) {
						formFieldsIndexes = ArrayUtil.append(formFieldsIndexes, -1);
					}
				}

				int index = 1;

				for (int formFieldsIndex : formFieldsIndexes) {
					request.setAttribute("configuration.jsp-index", String.valueOf(index));
					request.setAttribute("configuration.jsp-formFieldsIndex", String.valueOf(formFieldsIndex));
					request.setAttribute("configuration.jsp-fieldsEditingDisabled", String.valueOf(fieldsEditingDisabled));
				%>

					<div class="lfr-form-row" id="<portlet:namespace />fieldset<%= formFieldsIndex %>">
						<div class="row-fields">
							<liferay-util:include page="/edit_field.jsp" servletContext="<%= application %>" />
						</div>
					</div>

				<%
					index++;
				}
				%>

			</aui:fieldset>
		</liferay-ui:panel>
	</liferay-ui:panel-container>

	<aui:button-row>
		<aui:button type="submit" />
	</aui:button-row>
	<liferay-portlet:renderURL portletName="<%= PortletKeys.DOCUMENT_LIBRARY %>" var="selectFolderURL" windowState="<%= LiferayWindowState.POP_UP.toString() %>">
		<portlet:param name="struts_action" value='<%= "/document_library/select_folder" %>' />
	</liferay-portlet:renderURL>
<aui:script use="aui-base">
	A.one('#<portlet:namespace />selectFolderButton').on(
		'click',
		function(event) {
			var portletURL = Liferay.PortletURL.createURL(themeDisplay.getURLControlPanel());

			portletURL.setParameter('groupId', themeDisplay.getScopeGroupId());
			portletURL.setParameter('struts_action', '/document_library/select_folder');
			portletURL.setParameter('folderId', '0');

			portletURL.setPortletId('20');

			portletURL.setWindowState('pop_up');
			Liferay.Util.selectEntity(
				{
					dialog: {
						constrain: true,
						modal: true,
						width: 680
					},
					id: '_<%= PortletKeys.DOCUMENT_LIBRARY %>_selectFolder',
					title: '<liferay-ui:message arguments="folder" key="select-x" />',
					uri: '<%= selectFolderURL.toString() %>'
				},
				function(event) {
					console.log("ola");
					var folderData = {
						idString: 'newFolderId',
						idValue: event.folderid,
						nameString: 'folderName',
						nameValue: event.foldername
					};
					Liferay.Util.selectFolder(folderData, '<portlet:namespace />');
				}
			);
		}
	);
</aui:script>

</aui:form>

<c:if test="<%= !fieldsEditingDisabled %>">
	<aui:script use="aui-base,liferay-auto-fields">
		var toggleOptions = function(event) {
			var select = this;

			var formRow = select.ancestor('.lfr-form-row');
			var value = select.val();

			var optionsDiv = formRow.one('.options');

			if ((value == 'options') || (value == 'radio')) {
				optionsDiv.all('label').show();
				optionsDiv.show();
			}
			else if (value == 'paragraph') {

				// Show just the text field and not the labels since there
				// are multiple choice inputs

				optionsDiv.all('label').hide();
				optionsDiv.show();
			}
			else {
				optionsDiv.hide();
			}

			var optionalControl = formRow.one('.optional-control').ancestor();
			var labelName = formRow.one('.label-name');

			if (value == 'paragraph') {
				var inputName = labelName.one('input.field');

				var formFieldsIndex = select.attr('id').match(/\d+$/);

				inputName.val('<liferay-ui:message key="paragraph" />' + formFieldsIndex);
				inputName.fire('change');

				labelName.hide();
				optionalControl.hide();

				optionalControl.all('input[type="checkbox"]').attr('checked', 'true');
				optionalControl.all('input[type="hidden"]').attr('value', 'true');
			}
			else {
				optionalControl.show();
				labelName.show();
			}
		};

		var webFields = A.one('.webFields');

		webFields.all('select').each(toggleOptions);

		webFields.delegate(['change', 'click', 'keydown'], toggleOptions, 'select');

		<c:if test="<%= PortletPropsValues.VALIDATION_SCRIPT_ENABLED %>">
			var toggleValidationOptions = function(event) {
				this.next().toggle();
			};

			webFields.delegate('click', toggleValidationOptions, '.validation-link');
		</c:if>

		webFields.delegate(
			'change',
			function(event) {
				var input = event.currentTarget;
				var row = input.ancestor('.field-row');
				var label = row.one('.field-title');

				if (label) {
					label.html(input.get('value'));
				}
			},
			'.label-name input'
		);

		new Liferay.AutoFields(
			{
				contentBox: webFields,
				fieldIndexes: '<portlet:namespace />formFieldsIndexes',
				namespace: '<portlet:namespace />',
				sortable: true,
				sortableHandle: '.field-label',

				<liferay-portlet:renderURL portletConfiguration="true" var="editFieldURL" windowState="<%= LiferayWindowState.EXCLUSIVE.toString() %>">
					<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.ADD %>" />
				</liferay-portlet:renderURL>

				url: '<%= editFieldURL %>'
			}
		).render();
	</aui:script>
</c:if>