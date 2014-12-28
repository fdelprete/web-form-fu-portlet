web-form-fu-portlet
===================

Based on Liferay Web Form portlet: adde file upload capability and other misc.

This is a new Web Form portlet wich you can use with forms that need a file upload control.

The file is upload to disk (you can specify the absolute path location) or to a Documents and Media folder.

The file is attached to the email also.

You can configure the portlet to send a "thank you" email to the form's author (only if he's a registered user).

The import process (could be time consuming) is started as liferay BackgroundTask.

TO DO
- Managing BackgroundTastStatus
- Remove or decide to move server connection parameters in the configuration page.
- Mapping of Notes document category to liferay asset category.
- Mapping of Roles in Notes readers and authors field to liferay site roles.
