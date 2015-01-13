/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.fmdp.webform.portlet;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
//import java.io.Serializable;







import com.fmdp.webform.util.PortletPropsValues;
import com.fmdp.webform.util.WebFormUtil;
import com.liferay.counter.service.CounterLocalServiceUtil;
import com.liferay.mail.service.MailServiceUtil;
import com.liferay.portal.kernel.captcha.CaptchaTextException;
import com.liferay.portal.kernel.captcha.CaptchaUtil;
import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.mail.MailMessage;
import com.liferay.portal.kernel.portlet.PortletResponseUtil;
import com.liferay.portal.kernel.repository.model.FileEntry;
import com.liferay.portal.kernel.repository.model.Folder;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.kernel.util.CharPool;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ContentTypes;
import com.liferay.portal.kernel.util.FileUtil;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.LocalizationUtil;
import com.liferay.portal.kernel.util.MimeTypesUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.StringBundler;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
//import com.liferay.portal.kernel.workflow.WorkflowConstants;
//import com.liferay.portal.kernel.zip.ZipWriter;
//import com.liferay.portal.kernel.zip.ZipWriterFactoryUtil;
import com.liferay.portal.model.User;
import com.liferay.portal.security.permission.ActionKeys;
import com.liferay.portal.service.ServiceContext;
import com.liferay.portal.service.ServiceContextFactory;
import com.liferay.portal.service.permission.PortletPermissionUtil;
import com.liferay.portal.theme.ThemeDisplay;
import com.liferay.portal.util.PortalUtil;
import com.liferay.portlet.PortletPreferencesFactoryUtil;
//import com.liferay.portlet.documentlibrary.model.DLSyncConstants;
import com.liferay.portlet.documentlibrary.service.DLAppLocalServiceUtil;
//import com.liferay.portlet.documentlibrary.service.DLFileEntryLocalServiceUtil;
import com.liferay.portlet.expando.model.ExpandoRow;
import com.liferay.portlet.expando.service.ExpandoRowLocalServiceUtil;
import com.liferay.portlet.expando.service.ExpandoTableLocalServiceUtil;
import com.liferay.portlet.expando.service.ExpandoValueLocalServiceUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
//import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import javax.mail.internet.InternetAddress;
import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletException;
import javax.portlet.PortletPreferences;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

/**
 * @author Filippo Maria Del Prete
 * @author Daniel Weisser
 * @author Jorge Ferrer
 * @author Alberto Montero
 * @author Julio Camarero
 * @author Brian Wing Shun Chan
 */
public class WebFormPortlet extends MVCPortlet {

	public void deleteData(
			ActionRequest actionRequest, ActionResponse actionResponse)
		throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(
			WebKeys.THEME_DISPLAY);

		String portletId = PortalUtil.getPortletId(actionRequest);

		PortletPermissionUtil.check(
			themeDisplay.getPermissionChecker(), themeDisplay.getPlid(),
			portletId, ActionKeys.CONFIGURATION);

		PortletPreferences preferences =
			PortletPreferencesFactoryUtil.getPortletSetup(actionRequest);

		String databaseTableName = preferences.getValue(
			"databaseTableName", StringPool.BLANK);

		if (Validator.isNotNull(databaseTableName)) {
			ExpandoTableLocalServiceUtil.deleteTable(
				themeDisplay.getCompanyId(), WebFormUtil.class.getName(),
				databaseTableName);
		}
	}

	public void saveData(
			ActionRequest actionRequest, ActionResponse actionResponse)
		throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(
			WebKeys.THEME_DISPLAY);
        ServiceContext serviceContext = ServiceContextFactory.getInstance(actionRequest);

		String portletId = PortalUtil.getPortletId(actionRequest);

		PortletPreferences preferences =
			PortletPreferencesFactoryUtil.getPortletSetup(
				actionRequest, portletId);

		boolean requireCaptcha = GetterUtil.getBoolean(
			preferences.getValue("requireCaptcha", StringPool.BLANK));
		String successURL = GetterUtil.getString(
			preferences.getValue("successURL", StringPool.BLANK));
		boolean sendAsEmail = GetterUtil.getBoolean(
			preferences.getValue("sendAsEmail", StringPool.BLANK));
		boolean sendThanksEmail = GetterUtil.getBoolean(
				preferences.getValue("sendThanksEmail", StringPool.BLANK));
		boolean saveToDatabase = GetterUtil.getBoolean(
			preferences.getValue("saveToDatabase", StringPool.BLANK));
		String databaseTableName = GetterUtil.getString(
			preferences.getValue("databaseTableName", StringPool.BLANK));
		boolean saveToFile = GetterUtil.getBoolean(
			preferences.getValue("saveToFile", StringPool.BLANK));
		boolean uploadToDisk = GetterUtil.getBoolean(
				preferences.getValue("uploadToDisk", StringPool.BLANK));
		boolean uploadToDM = GetterUtil.getBoolean(
				preferences.getValue("uploadToDM", StringPool.BLANK));
		long newFolderId = GetterUtil.getLong(preferences.getValue("newFolderId", StringPool.BLANK));		
		String fileName = GetterUtil.getString(
			preferences.getValue("fileName", StringPool.BLANK));
		String uploadDiskDir = GetterUtil.getString(preferences.getValue(
				"uploadDiskDir", StringPool.BLANK));

		if (requireCaptcha) {
			try {
				CaptchaUtil.check(actionRequest);
			}
			catch (CaptchaTextException cte) {
				SessionErrors.add(
					actionRequest, CaptchaTextException.class.getName());

				return;
			}
		}

		UploadPortletRequest uploadRequest = PortalUtil.getUploadPortletRequest(actionRequest);

		Map<String, String> fieldsMap = new LinkedHashMap<String, String>();

		String fileAttachment = "";
		
		for (int i = 1; true; i++) {
			String fieldLabel = preferences.getValue(
				"fieldLabel" + i, StringPool.BLANK);

			String fieldType = preferences.getValue(
				"fieldType" + i, StringPool.BLANK);

			if (Validator.isNull(fieldLabel)) {
				break;
			}

			if (StringUtil.equalsIgnoreCase(fieldType, "paragraph")) {
				continue;
			}
			if (StringUtil.equalsIgnoreCase(fieldType, "file")) {
				if (_log.isDebugEnabled()) {
					_log.debug("Field name for file: " + fieldLabel);
				}
				
				File file = uploadRequest.getFile("field" + i);

				String sourceFileName = uploadRequest.getFileName("field" + i);
				if (_log.isDebugEnabled()) {
					_log.debug("File attachment: " + sourceFileName);
				}
				JSONObject jsonObject = JSONFactoryUtil.createJSONObject();

				if(Validator.isNotNull(sourceFileName) && !"".equals(sourceFileName)) {
					
					if (uploadRequest.getSize("field" + i) == 0) {
						SessionErrors.add(
								actionRequest, "uploadToDiskError", "Uploaded file size is 0");
						if (_log.isDebugEnabled()) {
							_log.debug("Uploaded file size is 0");
						}
						return;
					}
//					List<String> uploadResults = new ArrayList<String>();
					String uploadResult = "";
					if(uploadToDisk) {
						uploadResult = uploadFile(file, sourceFileName, uploadDiskDir);
						if (uploadResult.equalsIgnoreCase("File Upload Error")) {
							SessionErrors.add(
									actionRequest, "uploadToDiskError", uploadResult);
							return;
						}
						fileAttachment = uploadDiskDir + File.separator + uploadResult;
						//uploadResults.add(uploadResult);
						jsonObject.put("fsOriginalName", sourceFileName);
						jsonObject.put("fsName", uploadResult);
					}
					if(uploadToDM){
						uploadResult = "";
						String contentType = MimeTypesUtil.getContentType(file);
			            Folder folderName = DLAppLocalServiceUtil.getFolder(newFolderId);
						if (_log.isDebugEnabled()) {
							_log.debug("DM Folder: " + folderName.getName());
						}			            
			            InputStream inputStream  = new FileInputStream(file);
			            long repositoryId = folderName.getRepositoryId();
			            try {
			            	String selectedFileName = sourceFileName;
			    			while (true) {
			    				try {
			    					DLAppLocalServiceUtil.getFileEntry(
			    						themeDisplay.getScopeGroupId(), newFolderId,
			    						selectedFileName);

			    					StringBundler sb = new StringBundler(5);

			    					sb.append(FileUtil.stripExtension(selectedFileName));
			    					sb.append(StringPool.DASH);
			    					sb.append(StringUtil.randomString());
			    					sb.append(StringPool.PERIOD);
			    					sb.append(FileUtil.getExtension(selectedFileName));

			    					selectedFileName = sb.toString();
			    				}
			    				catch (Exception e) {
			    					break;
			    				}
			    			}

			            FileEntry fileEntry = DLAppLocalServiceUtil.addFileEntry(themeDisplay.getUserId(), 
                                repositoryId, 
                                newFolderId, 
                                selectedFileName, //file.getName(), 
                                contentType, 
                                selectedFileName, 
                                "", 
                                "", 
                                inputStream, 
                                file.length(), 
                                serviceContext);
						if (_log.isDebugEnabled()) {
							_log.debug("DM file uploade: " + fileEntry.getTitle());
						}			            
			            //Map<String, Serializable> workflowContext = new HashMap<String, Serializable>();
			            //workflowContext.put("event",DLSyncConstants.EVENT_UPDATE);
			            //DLFileEntryLocalServiceUtil.updateStatus(themeDisplay.getUserId(), fileEntry.getFileVersion().getFileVersionId(), WorkflowConstants.STATUS_APPROVED, workflowContext, serviceContext);
			            uploadResult = String.valueOf(fileEntry.getFileEntryId());
			            //uploadResults.add(uploadResult);
			            String docUrl = themeDisplay.getPortalURL()+"/c/document_library/get_file?uuid="+fileEntry.getUuid()+"&groupId="+themeDisplay.getScopeGroupId();
			            jsonObject.put("fe", uploadResult);
			            jsonObject.put("feOriginalName", sourceFileName);
			            jsonObject.put("feName", fileEntry.getTitle());
			            jsonObject.put("feUrl", docUrl);
			            } catch (PortalException pe) {
							SessionErrors.add(
									actionRequest, "uploadToDmError");
							_log.error("The upload to DM failed", pe);
			            	return;
			            } catch (Exception e) {
			            	_log.error("The upload to DM failed", e);
			            	return;
			            }
					}
					jsonObject.put("Status", "With Attachment");
				} else {
					jsonObject.put("Status", "No Attachment");
				}
				fieldsMap.put(fieldLabel, jsonObject.toString());				
			} else {
				fieldsMap.put(fieldLabel, uploadRequest.getParameter("field" + i));
			}
		}

		Set<String> validationErrors = null;

		try {
			validationErrors = validate(fieldsMap, preferences);
		}
		catch (Exception e) {
			SessionErrors.add(
				actionRequest, "validationScriptError", e.getMessage().trim());

			return;
		}

		User currentUser = PortalUtil.getUser(actionRequest);
		String userEmail = "";
		if (!Validator.isNull(currentUser)) {
			userEmail = currentUser.getEmailAddress();
			if (_log.isDebugEnabled()) {
				_log.debug("User email for the form author: " + userEmail);
			}
		
			fieldsMap.put("email-from", userEmail);
		} else {
			fieldsMap.put("email-from", "guest");
		}
	
		DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
		df.setTimeZone(TimeZone.getTimeZone(themeDisplay.getTimeZone().getID()));
		Date dateobj = new Date();
		fieldsMap.put("email-sent-on", df.format(dateobj));
		
		if (validationErrors.isEmpty()) {
			boolean emailSuccess = true;
			boolean databaseSuccess = true;
			boolean fileSuccess = true;
			boolean emailThanksSuccess = true;

			if (sendAsEmail) {
				emailSuccess = WebFormUtil.sendEmail(
					themeDisplay.getCompanyId(), fieldsMap, preferences, fileAttachment);
			}

			if (sendThanksEmail && !Validator.isNull(currentUser)) {
				emailThanksSuccess = WebFormUtil.sendThanksEmail(
					themeDisplay.getCompanyId(), fieldsMap, preferences, userEmail);
			}

			if (saveToDatabase) {
				if (Validator.isNull(databaseTableName)) {
					databaseTableName = WebFormUtil.getNewDatabaseTableName(
						portletId);

					preferences.setValue(
						"databaseTableName", databaseTableName);

					preferences.store();
				}

				databaseSuccess = saveDatabase(
					themeDisplay.getCompanyId(), fieldsMap, preferences,
					databaseTableName);
			}

			if (saveToFile) {
				fileSuccess = saveFile(fieldsMap, fileName);
			}

			if (emailSuccess && emailThanksSuccess && databaseSuccess && fileSuccess) {
				if (Validator.isNull(successURL)) {
					SessionMessages.add(actionRequest, "success");
				}
				else {
					SessionMessages.add(
						actionRequest,
						portletId +
							SessionMessages.
								KEY_SUFFIX_HIDE_DEFAULT_SUCCESS_MESSAGE);
				}
			}
			else {
				SessionErrors.add(actionRequest, "error");
			}
		}
		else {
			for (String badField : validationErrors) {
				SessionErrors.add(actionRequest, "error" + badField);
			}
		}

		if (SessionErrors.isEmpty(actionRequest) &&
			Validator.isNotNull(successURL)) {

			actionResponse.sendRedirect(successURL);
		}
	}

	@Override
	public void serveResource(
		ResourceRequest resourceRequest, ResourceResponse resourceResponse) {

		String cmd = ParamUtil.getString(resourceRequest, Constants.CMD);

		try {
			if (cmd.equals("captcha")) {
				serveCaptcha(resourceRequest, resourceResponse);
			}
			else if (cmd.equals("export")) {
				exportData(resourceRequest, resourceResponse);
			}
		}
		catch (Exception e) {
			_log.error(e, e);
		}
	}

	protected void exportData(
			ResourceRequest resourceRequest, ResourceResponse resourceResponse)
		throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay)resourceRequest.getAttribute(
			WebKeys.THEME_DISPLAY);

		String portletId = PortalUtil.getPortletId(resourceRequest);

		PortletPermissionUtil.check(
			themeDisplay.getPermissionChecker(), themeDisplay.getPlid(),
			portletId, ActionKeys.CONFIGURATION);

		PortletPreferences preferences =
			PortletPreferencesFactoryUtil.getPortletSetup(resourceRequest);

		String databaseTableName = preferences.getValue(
			"databaseTableName", StringPool.BLANK);
		String title = preferences.getValue("title", "no-title");

		StringBundler sb = new StringBundler();

		List<String> fieldLabels = new ArrayList<String>();

		for (int i = 1; true; i++) {
			String fieldLabel = preferences.getValue(
				"fieldLabel" + i, StringPool.BLANK);

			String localizedfieldLabel = LocalizationUtil.getPreferencesValue(
				preferences, "fieldLabel" + i, themeDisplay.getLanguageId());

			if (Validator.isNull(fieldLabel)) {
				break;
			}

			fieldLabels.add(fieldLabel);

			sb.append(getCSVFormattedValue(localizedfieldLabel));
			sb.append(PortletPropsValues.CSV_SEPARATOR);

		}
		fieldLabels.add("email-from");
		sb.append(getCSVFormattedValue("email-from"));
		sb.append(PortletPropsValues.CSV_SEPARATOR);

		fieldLabels.add("email-sent-on");
		sb.append(getCSVFormattedValue("email-sent-on"));
		sb.append(PortletPropsValues.CSV_SEPARATOR);

		sb.setIndex(sb.index() - 1);

		sb.append(CharPool.NEW_LINE);

		if (Validator.isNotNull(databaseTableName)) {
			List<ExpandoRow> rows = ExpandoRowLocalServiceUtil.getRows(
				themeDisplay.getCompanyId(), WebFormUtil.class.getName(),
				databaseTableName, QueryUtil.ALL_POS, QueryUtil.ALL_POS);

			for (ExpandoRow row : rows) {

				for (String fieldName : fieldLabels) {
					
					String data = ExpandoValueLocalServiceUtil.getData(
							themeDisplay.getCompanyId(),
							WebFormUtil.class.getName(), databaseTableName,
							fieldName, row.getClassPK(), StringPool.BLANK);

					sb.append(getCSVFormattedValue(data));
					sb.append(PortletPropsValues.CSV_SEPARATOR);
				}

				sb.setIndex(sb.index() - 1);

				sb.append(CharPool.NEW_LINE);
			}
		}
		
		String fileName = title + ".csv";
		byte[] bytes = sb.toString().getBytes();
		String contentType = ContentTypes.APPLICATION_TEXT;
		
		PortletResponseUtil.sendFile(
			resourceRequest, resourceResponse, fileName, bytes, contentType);
	}

	protected String getCSVFormattedValue(String value) {
		StringBundler sb = new StringBundler(3);

		sb.append(CharPool.QUOTE);
		sb.append(
			StringUtil.replace(value, CharPool.QUOTE, StringPool.DOUBLE_QUOTE));
		sb.append(CharPool.QUOTE);

		return sb.toString();
	}

	protected String getMailBody(Map<String, String> fieldsMap) {
		StringBundler sb = new StringBundler();

		for (String fieldLabel : fieldsMap.keySet()) {
			String fieldValue = fieldsMap.get(fieldLabel);

			sb.append(fieldLabel);
			sb.append(" : ");
			sb.append(fieldValue);
			sb.append(CharPool.NEW_LINE);
		}

		return sb.toString();
	}

	protected boolean saveDatabase(
			long companyId, Map<String, String> fieldsMap,
			PortletPreferences preferences, String databaseTableName)
		throws Exception {

		WebFormUtil.checkTable(companyId, databaseTableName, preferences);

		long classPK = CounterLocalServiceUtil.increment(
			WebFormUtil.class.getName());

		try {
			for (String fieldLabel : fieldsMap.keySet()) {
				String fieldValue = fieldsMap.get(fieldLabel);
//				System.out.println("field-> " + fieldLabel +" = " + fieldValue);
				ExpandoValueLocalServiceUtil.addValue(
					companyId, WebFormUtil.class.getName(), databaseTableName,
					fieldLabel, classPK, fieldValue);
			}

			return true;
		}
		catch (Exception e) {
			_log.error(
				"The web form data could not be saved to the database", e);

			return false;
		}
	}

	protected boolean saveFile(Map<String, String> fieldsMap, String fileName) {
		StringBundler sb = new StringBundler();

		for (String fieldLabel : fieldsMap.keySet()) {
			String fieldValue = fieldsMap.get(fieldLabel);

			sb.append(getCSVFormattedValue(fieldValue));
			sb.append(PortletPropsValues.CSV_SEPARATOR);
		}

		sb.setIndex(sb.index() - 1);

		sb.append(CharPool.NEW_LINE);

		try {
			FileUtil.write(fileName, sb.toString(), false, true);

			return true;
		}
		catch (Exception e) {
			_log.error("The web form data could not be saved to a file", e);

			return false;
		}
	}

	protected void serveCaptcha(
			ResourceRequest resourceRequest, ResourceResponse resourceResponse)
		throws Exception {

		CaptchaUtil.serveImage(resourceRequest, resourceResponse);
	}

	protected Set<String> validate(
			Map<String, String> fieldsMap, PortletPreferences preferences)
		throws Exception {

		Set<String> validationErrors = new HashSet<String>();

		for (int i = 0; i < fieldsMap.size(); i++) {
			String fieldType = preferences.getValue(
				"fieldType" + (i + 1), StringPool.BLANK);
			String fieldLabel = preferences.getValue(
				"fieldLabel" + (i + 1), StringPool.BLANK);
			String fieldValue = fieldsMap.get(fieldLabel);

			boolean fieldOptional = GetterUtil.getBoolean(
				preferences.getValue(
					"fieldOptional" + (i + 1), StringPool.BLANK));

			if (Validator.equals(fieldType, "paragraph")) {
				continue;
			}

			if (!fieldOptional && Validator.isNotNull(fieldLabel) &&
				Validator.isNull(fieldValue)) {

				validationErrors.add(fieldLabel);

				continue;
			}

			if (!PortletPropsValues.VALIDATION_SCRIPT_ENABLED) {
				continue;
			}

			String validationScript = GetterUtil.getString(
				preferences.getValue(
					"fieldValidationScript" + (i + 1), StringPool.BLANK));

			if (Validator.isNotNull(validationScript) &&
				!WebFormUtil.validate(
					fieldValue, fieldsMap, validationScript)) {

				validationErrors.add(fieldLabel);

				continue;
			}
		}

		return validationErrors;
	}
	public String uploadFile(File file, String sourceFileName, String folder)
			throws PortletException, 
			IOException {

		//String realPath = getPortletContext().getRealPath("/");
		String fsep = File.separator;

		if (_log.isDebugEnabled()) {
			_log.debug("Folder to upload: " + folder);
		}

		try {
			
			if (_log.isDebugEnabled()) {
				_log.debug("Source file name to upload: " + sourceFileName);
			}

			File newFolder = null;
			newFolder = new File(folder);
			if(!newFolder.exists()){
				newFolder.mkdir();
			}
			File newfile = null;
			String filename = newFolder.getAbsoluteFile() + fsep + sourceFileName;
			String originalFileName = sourceFileName;
			newfile = new File(filename);
			int j = 0;
			
			while (newfile.exists()) {
		        j++;
		        String ext = FileUtil.getExtension(originalFileName);
		        filename = newFolder.getAbsoluteFile() + fsep + stripExtension(originalFileName) + "(" + Integer.toString(j) +")." + ext ;
		        newfile = new File(filename);
		    }
			if (_log.isDebugEnabled()) {
				_log.debug("New file name: " + newfile.getName());
				_log.debug("New file path: " + newfile.getPath());
			}

			FileInputStream fis = new FileInputStream(file);
			FileOutputStream fos = new FileOutputStream(newfile);

			byte[] bytes_ = FileUtil.getBytes(file);
			int i = fis.read(bytes_);

			while (i != -1) {
				fos.write(bytes_, 0, i);
				i = fis.read(bytes_);
			}
			fis.close();
			fos.close();
			Float size = (float) newfile.length();
			if (_log.isDebugEnabled()) {
				_log.debug("file size bytes: " + size);
				_log.debug("file size Mb: "  + size / 1048576);
				_log.debug("File created: " + newfile.getName());
			}

			return newfile.getName();

		} catch (FileNotFoundException e) {
			_log.error("File Not Found.");
			e.printStackTrace();
			return "File Upload Error";
		} catch (NullPointerException e) {
			_log.error("File Not Found.");
			e.printStackTrace();
			return "File Upload Error";
		}

		catch (IOException e1) {
			_log.error("Error Reading The File.");
			e1.printStackTrace();
			return "File Upload Error.";
		}

	}


	private String stripExtension (String str) {

        if (str == null) return null;

        int pos = str.lastIndexOf(".");

        if (pos == -1) return str;

        return str.substring(0, pos);
    }

	private static Log _log = LogFactoryUtil.getLog(WebFormPortlet.class);

}