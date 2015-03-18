<cfcomponent displayName=.GIT_report" hint="asdf">
	<cfset variables.podImagePath = "http://www.callholder_GIT.com/images/pods/" />

	<cffunction name="prepar.GIT_report" returnType="struct">
		<cfargument name=.GIT_reportID" required="yes" type="numeric">

		<cfscript>
			theStructure = structNew();
			theStructure.Profile 	= ge.GIT_reportID=arguments.GIT_reportID);
			theStructure.Content 	= getContent.GIT_report_contentID=theStructure.Profile['.GIT_report_contentID'],.GIT_reportID=arguments.GIT_reportID);
			theStructure.Container 	= getContainer.GIT_report_containerID=theStructure.Profile['.GIT_report_containerID']);
			theStructure.Hco		= getHco.GIT_reportID=arguments.GIT_reportID);
			theStructure.Calls 		= getCalls.GIT_reportID=#arguments.GIT_reportID#,.GIT_report_schedule=theStructure.Profile['.GIT_report_scheduleID'], contentID=theStructure.Profile['.GIT_report_contentID']);
			theStructure.Recipient 	= getRecipient.GIT_reportID=#arguments.GIT_reportID#);
			theStructure.Pods 		= getPods.GIT_reportID=#arguments.GIT_reportID#);
			theStructure.Disclaimer = getDisclaimer.GIT_report_disclaimerid=theStructure.Profile['.GIT_report_disclaimerid']);
		</cfscript>

        <cfreturn theStructure>
    </cffunction>

	<cffunction name="generat.GIT_reportHTML" returnType="string">
		<cfargument name="thi.GIT_report" required="yes" type="struct">

		<cfsavecontent variable="htmlOutput">
			<cfif isDefined("url.phonedamentals")>
				<cfinclude template="../templates.GIT_report_phonedamentals.cfm" />
			<cfelseif isDefined("url.templateTest")>
				<cfinclude template="../templates.GIT_report_staff.cfm">
			<cfelseif thi.GIT_report.Container['refname'] EQ 'Phonedamentals'>
				<cfinclude template="../templates.GIT_report_phonedamentals.cfm" />
			<cfelseif thi.GIT_report.Container['refname'] EQ 'Phonex Managers - No Action'>
				<cfinclude template="../templates/phonex_managers_noAction.cfm" />
			<cfelseif thi.GIT_report.Container['refname'] EQ 'Phonex Managers'>
				<cfinclude template="../templates/phonex_managers.cfm" />
			<cfelse>
				<cfinclude template="../views/header.cfm" />	<!---Calls--->
				<cfinclude template="../views/content.cfm" />	<!---Content--->
				<cfinclude template="../views/callList.cfm" />	<!---Calls--->
				<cfinclude template="../views/pods.cfm" />		<!---Pods--->
				<cfinclude template="../views/footer.cfm" />	<!---Pods--->
			</cfif>
		</cfsavecontent>

        <cfreturn replaceEmailLinks(thi.GIT_reportHTML=htmlOutput)>
    </cffunction>

	<cffunction name="sen.GIT_report" returnType="array">
		<cfargument name="thi.GIT_report" required="yes" type="struct">
		<cfargument name="thi.GIT_reportHTML" required="yes" type="string">

		<cfset returnActivity = ArrayNew(1) />	<!---an array of structures that will return email recipient activity--->

		<!---verify there are recipients and a valid subject exists--->
		<cfif ArrayLen(thi.GIT_report.recipient) AND LEN(thi.GIT_report.profile['subject'])>
			<cfloop array="#thi.GIT_report.recipient#" index="this_recep_GIT"><!---loop over recipients--->
				<!--- verify email is valid--->
				<cfif NOT isValid('email',this_recep_GIT.recipient)>
					EMAIL IS NOT VALID!<cfabort />
				</cfif>

				<!---generate custom html--->
				<cfset recipientHTML = populateEmailVariables(this_recep_GIT,arguments.thi.GIT_reportHTML) />

				<!---include callid in the subject if email is an individual call alert--->
				<cfif thi.GIT_report.profile['.GIT_report_scheduleID'] EQ 11>
					<cfset var thisSubject = thi.GIT_report.profile['subject']&" For Callid "&thi.GIT_report.Calls[1].callid>
				<cfelse>
					<cfset var thisSubject = thi.GIT_report.profile['subject']>
				</cfif>

				<cfif thi.GIT_report.Container['refname'] EQ 'Phonex Managers - No Action'>
					<cfset sender = 'Car Wars'>
				<cfelse>
					<cfset sender = 'Call Report'>
				</cfif>

				<!---send email--->
				<cfmail subject="#thisSubject#"
						to="#this_recep_GIT.recipient#"
						from="#sender# <no-reply@callholder_GIT.com>"
						type="html">
					#variables.recipientHTML#
				</cfmail>

				<!---log email activity--->
				<cfscript>
					logEmail(recipient=this_recep_GIT);			/*log the email send action; update lastSent timestamps*/
					logCallsEmailed(theCalls=thi.GIT_report.Calls, emailzzidGIT=this_recep_GIT.zzidGIT);
					ArrayAppend(returnActivity,this_recep_GIT);
				</cfscript>
			</cfloop>
		</cfif>

		<cfreturn returnActivity >
    </cffunction>

	<cffunction name="replaceEmailLinks" returnType="string" hint="replaces links in the emails to the.GIT_report format">
		<cfargument name="thi.GIT_reportHTML" required="yes" type="string">

		<cfset ne.GIT_reportHTML = thi.GIT_reportHTML />
		<cfset ne.GIT_reportHTML = replace(ne.GIT_reportHTML,'http://www.callholder_GIT.com/review_x.cfm?','http://www.callholder_GIT.com.GIT_report/touch.cfm?e=@@EMAILzzidGIT@@&a=cc&','all') />	<!---new value is URL Encoded--->

		<cfreturn ne.GIT_reportHTML>
	</cffunction>

	<cffunction name="populateEmailVariables" returnType="string" hint="replaces placeholder variables in the email with values">
		<cfargument name="this_recep_GIT" required="yes" type="struct">
		<cfargument name="thi.GIT_reportHTML" required="yes" type="string">

		<cfscript>
			ne.GIT_reportHTML = thi.GIT_reportHTML;

			emailVariableMapping = StructNew();	/*mapping placeholder variables used in the HTML to the actual values; All values are URL encoded below*/
			StructInsert(emailVariableMapping,'@@EMAILzzidGIT@@',this_recep_GIT.zzidGIT);
			StructInsert(emailVariableMapping,'@@RECIPIENTEMAIL@@',this_recep_GIT.recipient);

			keysToStruct = StructKeyArray(emailVariableMapping);
		</cfscript>

		<cfloop index = "i" from = "1" to = "#ArrayLen(keysToStruct)#"> <!---loop over array of emailVariableMappings, and replace values--->
			<cfset ne.GIT_reportHTML = replace(ne.GIT_reportHTML,keysToStruct[i], URLEncodedFormat(emailVariableMapping[keysToStruct[i]]),'all') />	<!---new value is URL Encoded--->
		</cfloop>

		<cfreturn ne.GIT_reportHTML>
	</cffunction>

	<cffunction name="logCallsEmailed" returnType="void" hint="log all of the calls sent with an email">
		<cfargument name="theCalls" required="yes" type="array">
		<cfargument name="emailzzidGIT" required="yes" type="string">

		<cfif ArrayLen(theCalls)>	<!---only insert calls if they exist--->
			<cfquery datasource="callholder_GIT">
				INSERT INTO callholder_GIT.dbo.log_email_git (call_id_git,zzidGIT)
				VALUES
				<cfloop from="1" to="#ArrayLen(theCalls)#" index="i">
					<cfif i NEQ 1>,</cfif>(#theCalls[i].callid#, '#arguments.emailzzidGIT#')
				</cfloop>
			</cfquery>
		</cfif>
    </cffunction>

	<cffunction name="logEmail" returnType="void" hint="logs the email action, AND updates.GIT_report_recipient tables">
		<cfargument name="recipient" required="yes" type="struct">

		<cfquery datasource="callholder_GIT">
			INSERT INTO callholder_GIT.dbo.GIT_report_email_log .GIT_reportID, recipient, zzidGIT, report_date_start, report_date_end, generate_start, sent,.GIT_report_recipientID)
			VALUES (#recipient.GIT_reportid#, '#recipient.recipient#', '#recipient.zzidGIT#', '1900-01-01', '2099-01-01', '1970-01-01', #CreateODBCDateTime(now())#,
			#recipient.id#);

			DECLARE @new.GIT_report_email_logID bigint = SCOPE_IDENTITY();

			UPDATE callholder_GIT.dbo.GIT_report
			SET lastSent = GETDATE()
			WHERE id = #recipient.GIT_reportid#;

			UPDATE callholder_GIT.dbo.GIT_report_recipient
			SET lastSent = GETDATE()
			WHERE id = #recipient.id#;
		</cfquery>
    </cffunction>

	<cffunction name="ge.GIT_report" returnType="struct">
		<cfargument name=".GIT_reportID" required="yes" type="numeric">

         <cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT
				ID
				,.GIT_report_scheduleID
				,.GIT_report_containerID
				,.GIT_report_contentID
				, accountID
				, subject
				, isActive
				, lastSent
				, created
				, deactivated
				, callListOutputLimit
				, ISNULL.GIT_report_disclaimerid,0) as '.GIT_report_disclaimerid'
				, ISNULL(hd.product_domain,'callholder_GIT.com') as 'product_domain'
			FROM callholder_GIT.dbo.GIT_report a
				LEFT JOIN wdb7000.humanatic.dbo.hproduct_domain hd on hd.frn_hproductid = a.frn_hproductid
			WHERE id = .GIT_reportID#
				AND isActive = 1
         </cfquery>

         <cfreturn QueryToStruct(theQuery,1)>
    </cffunction>

    <cffunction name="getContainer" returnType="struct">
		<cfargument name=".GIT_report_containerID" required="yes" type="numeric">

         <cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT
				refname
				, header
				, footer
			FROM callholder_GIT.dbo.GIT_report_Container a
			WHERE id = .GIT_report_containerID#
         </cfquery>

         <cfreturn QueryToStruct(theQuery,1)>
    </cffunction>

    <cffunction name="getContent" returnType="struct">
		<cfargument name=.GIT_report_contentID" required="yes" type="numeric">
		<cfargument name=.GIT_reportID" required="yes" type="numeric">

         <cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT content
			FROM callholder_GIT.dbo.GIT_report_Content a
			WHERE id = .GIT_report_contentID#
         </cfquery>
		 <cfif theQuery.content EQ ''>
			<cfquery name="theQuery" datasource="callholder_GIT">
				SELECT message_text as content
				FROM callholder_GIT.dbo.GIT_report_message
				WHERE.GIT_reportID = .GIT_reportID#
			</cfquery>
		 </cfif>

         <cfreturn QueryToStruct(theQuery,1)>
    </cffunction>

	<cffunction name="getDisclaimer" returnType="struct">
		<cfargument name=".GIT_report_disclaimerid" required="yes" type="numeric">

         <cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT disclaimer_message
			FROM callholder_GIT.dbo.GIT_report_disclaimer a
			WHERE id = .GIT_report_disclaimerid#
         </cfquery>

         <cfreturn QueryToStruct(theQuery,1)>

    </cffunction>

    <cffunction name="getRecipient" returnType="array">
		<cfargument name=".GIT_reportID" required="yes" type="numeric">

         <cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT a.*, l.descrip1
				, NEWID() AS 'zzidGIT'	/*zzidGIT is generated here to speed up the sending process*/
			FROM callholder_GIT.dbo.GIT_report_recipient a
				LEFT JOIN callholder_GIT.dbo.leuser l ON l.leuserid = a.frn_leuserid
			WHERE a.GIT_reportID = .GIT_reportID#
				AND a.isActive = 1
         </cfquery>

		<cfscript>
			LogRecipientzzidGIT.GIT_reportID=arguments.GIT_reportID, theRecipient=theQuery);
		</cfscript>

         <cfreturn QueryToArrayOfStructures(theQuery)>
    </cffunction>

	<cffunction name="LogRecipientzzidGIT" returnType="void">
		<cfargument name=".GIT_reportID" required="yes" type="numeric">
		<cfargument name="theRecipient" required="yes" type="query">

		<cfquery datasource="callholder_GIT" name="LogzzidGIT">
			INSERT INTO.GIT_report_recipient_log .GIT_reportID, recipient, zzidGIT)
			VALUES (#arguments.GIT_reportID#, '#arguments.theRecipient.recipient#', '#arguments.theRecipient.zzidGIT#');
		</cfquery>
	</cffunction>

	<cffunction name="getHco" returnType="array">
		<cfargument name=".GIT_reportID" required="yes" type="numeric">

		<cfquery datasource="callholder_GIT" name="theQuery">
			SELECT hco.GIT_category_optionID
			FROM.GIT_report a
				INNER JOIN.GIT_report_hco hco ON a.ID = hco.GIT_reportID
			WHERE a.ID = #arguments.GIT_reportID#
		</cfquery>

		<cfreturn QueryToArrayOfStructures(theQuery)>
	</cffunction>

	<cffunction name="getPods" returnType="array">
		<cfargument name=GIT_reportID required="yes" type="numeric">

         <cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT
				p.podid
				, p.pod_name
				, '#variables.podImagePath#'+p.pod_image as 'pod_image'
				, p.pod_description
			FROM callholder_GIT.dbo.GIT_report_pod axp
				inner join callholder_GIT.dbo.pod p ON axp.podid = p.podid
			WHERE
				axp.GIT_reportid=#arguments.GIT_reportID#
				AND ISNULL(p.pod_image,'') <> ''
         </cfquery>

         <cfreturn QueryToArrayOfStructures(theQuery)>
    </cffunction>

	<cffunction name="getCalls" returnType="array">
		<cfargument name=.GIT_reportID" required="yes" type="numeric">
		<cfargument name=.GIT_report_schedule" required="yes" type="numeric">
		<cfargument name="contentID" required="yes" type="numeric">

		<!---if a call_list has been provided for this.GIT_report, then use those calls--->
		<cfscript>callListToReturn = getCallsByCallList.GIT_reportID=#arguments.GIT_reportID#,.GIT_report_schedule=#arguments.GIT_report_schedule#);</cfscript>

		<cfif NOT arrayLen(callListToReturn)>	<!---if no call list can be found, check for calls via associated phonecode and Humanatic Option--->
			<cfscript>callListToReturn = getCallsByPhonecode.GIT_reportID=#arguments.GIT_reportID#,.GIT_report_schedule=#arguments.GIT_report_schedule#, contentID=arguments.contentID);</cfscript>
		</cfif>

		<cfif NOT arrayLen(callListToReturn)>	<!---if no call list can be found, check for calls via associated Humanatic Option--->
			<cfscript>callListToReturn = getCallsByHumanaticOption.GIT_reportID=#arguments.GIT_reportID#,.GIT_report_schedule=#arguments.GIT_report_schedule#);</cfscript>
		</cfif>

		<cfif NOT arrayLen(callListToReturn)>	<!---if no call list can be found, check for coached calls--->
			<cfscript>callListToReturn = getCoachedCalls.GIT_reportID=#arguments.GIT_reportID#,.GIT_report_schedule=#arguments.GIT_report_schedule#);</cfscript>
		</cfif>

		<cfif arrayLen(callListToReturn)>	<!---log calls that are returned--->
			<cfscript>logCallsReturned(arrayOfCallids=#callListToReturn#);</cfscript>
		</cfif>

		<cfreturn callListToReturn>
	</cffunction>

	<cffunction name="logCallsReturned" returnType="void">
		<cfargument name="arrayOfCallids" required="no" type="array">

		<cfset callListToLog = "" />

		<!---   log calls that are returned   --->
			<cfloop array="#arrayOfCallids#" index="thisCall">
				<cfset callListToLog = callListToLog&"#thisCall.callid#,">
			</cfloop>

			<cfif RIGHT(callListToLog,1) EQ ",">
				<cfset callListToLog = LEFT(callListToLog,LEN(callListToLog)-1)/>
			</cfif>

			<!---@@@insert into table here!--->
	</cffunction>

	<cffunction name="getCallsByHumanaticOption" returnType="array">
		<cfargument name=.GIT_reportID" required="yes" type="numeric">
		<cfargument name=.GIT_report_schedule" required="yes" type="numeric">

		<!--- end date will always be today --->
		<cfset end = DateFormat(Now(), 'yyyy-mm-dd')>
		<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')> <!--- default start date --->
		<!--- determine start date based on.GIT_report_scheduleid --->
		<cfswitch expression="#arguments.GIT_report_schedule#">
			<cfcase value="1"> <!--- daily --->
				<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="2"> <!--- Monthly --->
				<cfset start = DateFormat(DateAdd('m',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="3"> <!--- Onetime --->
				<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="4,5,6,7,8,9,10"> <!--- Weekly options --->
				<cfset start = DateFormat(DateAdd('d',-7,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="11"> <!--- Individual Alerts --->
				<cfset start = DateFormat(Now(),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="12"> <!--- Daily - Weekdays --->
				<cfif DayOfWeek(Now()) EQ 2>
					<cfset start = DateFormat(DateAdd('d',-3,Now()),'yyyy-mm-dd')>
				<cfelse>
					<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
				</cfif>
			</cfcase>
		</cfswitch>

		<cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT DISTINCT <cfif arguments.GIT_report_schedule EQ 11>top 1</cfif>
				row_number() OVER(ORDER BY c.tz_datetime DESC) as rowNumber, c.callid, p.call_begin_datetime
			FROM
				(SELECT accountID FROM.GIT_report WHERE ID = #arguments.GIT_reportID#) l
				INNER JOIN git_phoneLINES d ON d.add_lskinid = l.accountID
				INNER JOIN _git_call_datalong c ON c.cf_frn_git_phoneLINESid = d.git_phoneLINESid
				INNER JOIN _git_call_datalong_GIT_category h ON h.frn_callid = c.callid
				INNER JOIN _git_call_datalong_platform p ON p.frn_callid = c.callid
				LEFT JOIN.GIT_report_git_phoneLINES ad ON ad.GIT_reportID = #arguments.GIT_reportID#
			WHERE
				h.frn_GIT_category_optionid IN (SELECT DISTINCT GIT_category_optionID FROM.GIT_report_hco WHERE.GIT_reportid = #arguments.GIT_reportID#)
				AND c.tz_date >= '#start#'
				AND c.tz_date < '#end#'
				AND (c.cf_frn_git_phoneLINESid = ad.frn_git_phoneLINESid OR ad.frn_git_phoneLINESid IS NULL)
				AND (c.extension_frn_git_phoneLINESid = ad.frn_extension OR ad.frn_extension IS NULL)
		</cfquery>

		<cfreturn QueryToArrayOfStructures(theQuery)>
	</cffunction>

	<cffunction name="getCoachedCalls" returnType="array">
		<cfargument name=.GIT_reportID" required="yes" type="numeric">
		<cfargument name=.GIT_report_schedule" required="yes" type="numeric">

		<!--- end date will always be today --->
		<cfset end = DateFormat(Now(), 'yyyy-mm-dd')>
		<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')> <!--- default start date --->
		<!--- determine start date based on.GIT_report_scheduleid --->
		<cfswitch expression="#arguments.GIT_report_schedule#">
			<cfcase value="1"> <!--- daily --->
				<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="2"> <!--- Monthly --->
				<cfset start = DateFormat(DateAdd('m',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="3"> <!--- Onetime --->
				<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="4,5,6,7,8,9,10"> <!--- Weekly options --->
				<cfset start = DateFormat(DateAdd('d',-7,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="11"> <!--- Individual Alerts --->
				<cfset start = DateFormat(Now(),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="12"> <!--- Daily - Weekdays --->
				<cfif DayOfWeek(Now()) EQ 2>
					<cfset start = DateFormat(DateAdd('d',-3,Now()),'yyyy-mm-dd')>
				<cfelse>
					<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
				</cfif>
			</cfcase>
		</cfswitch>

		<cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT DISTINCT <cfif arguments.GIT_report_schedule EQ 11>top 1</cfif>
				c.callid, p.call_begin_datetime
			FROM
			.GIT_report l
				INNER JOIN.GIT_report_coaching ac ON ac.GIT_reportID = l.ID
				INNER JOIN xgit_phoneLINES d ON d.add_lskinid = l.accountID
				INNER JOIN vw_GIT_call_data c ON c.cf_frn_git_phoneLINESid = d.git_phoneLINESid
				INNER JOIN vw_GIT_call_data_platform p ON p.frn_callid = c.callid
				INNER JOIN call_coaching cc ON cc.frn_callid = c.callid
			WHERE l.ID = #arguments.GIT_reportID#
				AND cc.date_coached >= '#start#'
				AND cc.date_coached < '#end#'
				AND cc.date_coached >= l.created
		</cfquery>

		<cfreturn QueryToArrayOfStructures(theQuery)>
	</cffunction>

	<cffunction name="getCallsByPhonecode" returnType="array">
		<cfargument name=.GIT_reportID" required="yes" type="numeric">
		<cfargument name=.GIT_report_schedule" required="yes" type="numeric">
		<cfargument name="contentID" required="yes" type="numeric">

		<!--- end date will always be today --->
		<cfset end = DateFormat(Now(), 'yyyy-mm-dd')>
		<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')> <!--- default start date --->
		<!--- determine start date based on.GIT_report_scheduleid --->
		<cfswitch expression="#arguments.GIT_report_schedule#">
			<cfcase value="1"> <!--- daily --->
				<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="2"> <!--- Monthly --->
				<cfset start = DateFormat(DateAdd('m',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="3"> <!--- Onetime --->
				<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="4,5,6,7,8,9,10"> <!--- Weekly options --->
				<cfset start = DateFormat(DateAdd('d',-7,Now()),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="11"> <!--- Individual Alerts --->
				<cfset start = DateFormat(Now(),'yyyy-mm-dd')>
			</cfcase>
			<cfcase value="12"> <!--- Daily - Weekdays --->
				<cfif DayOfWeek(Now()) EQ 2>
					<cfset start = DateFormat(DateAdd('d',-3,Now()),'yyyy-mm-dd')>
				<cfelse>
					<cfset start = DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>
				</cfif>
			</cfcase>
		</cfswitch>

		<cfif arguments.contentID EQ 5>
			<cfset start = DateFormat(DateAdd('d',-7,Now()),'yyyy-mm-dd')>
		</cfif>

		<cfquery name="hco" datasource="callholder_GIT" >
			SELECT DISTINCT GIT_category_optionID FROM.GIT_report_hco WHERE.GIT_reportid = #arguments.GIT_reportID#
		</cfquery>

		<cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT DISTINCT <cfif arguments.GIT_report_schedule EQ 11>top 1</cfif>
				<!---row_number() OVER(ORDER BY c.tz_datetime DESC) as rowNumber,---> c.callid, p.call_begin_datetime
			FROM
				(SELECT accountID FROM.GIT_report WHERE ID = #arguments.GIT_reportID#) l
				INNER JOIN git_phoneLINES d ON d.add_lskinid = l.accountID
				INNER JOIN _git_call_datalong c ON c.cf_frn_git_phoneLINESid = d.git_phoneLINESid
				INNER JOIN _git_call_datalong_platform p ON p.frn_callid = c.callid
				LEFT JOIN _git_call_datalong_GIT_category h ON h.frn_callid = c.callid
				LEFT JOIN.GIT_report_git_phoneLINES ad ON ad.GIT_reportID = #arguments.GIT_reportID#
			WHERE
				c.frn_phonecodeid IN (SELECT DISTINCT frn_phonecodeid FROM.GIT_report_phonecode WHERE.GIT_reportid = #arguments.GIT_reportID#)
				<cfif hco.recordCount GT 0>
					AND h.frn_GIT_category_optionid IN (#Valuelist(hco.GIT_category_optionID)#)
				</cfif>
				AND c.tz_date >= '#start#'
				AND c.tz_date < '#end#'
				AND (c.cf_frn_git_phoneLINESid = ad.frn_git_phoneLINESid OR ad.frn_git_phoneLINESid IS NULL)
				AND (c.extension_frn_git_phoneLINESid = ad.frn_extension OR ad.frn_extension IS NULL)
			ORDER BY p.call_begin_datetime DESC
		</cfquery>

		<cfreturn QueryToArrayOfStructures(theQuery)>
	</cffunction>

	<cffunction name="getCallsByCallList" returnType="array">
		<cfargument name=.GIT_reportID" required="yes" type="numeric">
		<cfargument name=.GIT_report_schedule" required="yes" type="numeric">

		<cfquery name="theQuery" datasource="callholder_GIT" >
			WITH x AS (
				SELECT <cfif arguments.GIT_report_schedule EQ 11>top 1</cfif> GIT.callid, p.call_begin_datetime, GIT.complete
					FROM
						callholder_GIT.dbo.GIT_report_call_list AX
						INNER JOIN vw_GIT_call_data_platform p ON p.frn_callid = GIT.callid
					WHERE
						GIT.GIT_reportid = #arguments.GIT_reportID#
						AND GIT.complete = 0
					<cfif arguments.GIT_report_schedule EQ 11>ORDER BY p.call_begin_datetime ASC</cfif>
				)
			UPDATE x set complete = 1
			OUTPUT inserted.callid
		</cfquery>

         <!---<cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT DISTINCT <cfif arguments.GIT_report_schedule EQ 11>top 1</cfif> row_number() OVER(ORDER BY p.call_begin_datetime ASC) as rowNumber, GIT.callid, p.call_begin_datetime
			FROM
				callholder_GIT.dbo.GIT_report_call_list AX
				INNER JOIN vw_git_call_data_quick_2014_platform p ON p.frn_callid = GIT.callid
			WHERE
				GIT.GIT_reportid = #arguments.GIT_reportID#
				AND GIT.complete = 0
			ORDER BY p.call_begin_datetime ASC
         </cfquery> --->

		 <!---<cfquery name="theQuery" datasource="callholder_GIT" >
			SELECT
				c.callid
				, c.tz_date
				, d.tz_time
				, d.call_duration
				, disp.disposition
				, label0.git_phoneLINES_label as 'displaynum'
				, label1.git_phoneLINES_label
				, bridgeValue.git_phoneLINES_label as 'bridgeval'
				, d.pickup_time
				, leminutes_precise-(CAST(pickup_time AS FLOAT)/60) AS 'talkTime'
				, ani.theani
				, ani.ani_name
				, ani.ani_address
				, ani.ani_city
				, ani.ani_state
				, ani.ani_zipcode
				, pc.phonecodeid, pc.lename as 'phonecode_name', pc.pc_avatar as 'phonecode_avatar'
				, STUFF((select ', '+ho.reporting_filter
									from callholder_GIT.dbo.vw_git_call_data_quick_2014_GIT_category ch
										inner join GIT_category h on h.GIT_categoryid = ch.frn_GIT_categoryid
										inner join GIT_category_option ho on ho.GIT_category_optionid = ch.frn_GIT_category_optionid AND ho.frn_GIT_categoryid = ch.frn_GIT_categoryid
									where ch.frn_callid = c.callid
										AND ISNULL(ho.reporting_filter,'') <> ''
									order by h.GIT_category_rank
									for xml path('')),1,1,'') as 'humanatic_reporting_filters'
			FROM
				callholder_GIT.dbo.GIT_report_call_list AX
				INNER JOIN callholder_GIT.dbo.vw_git_call_data_quick_2014 c on GIT.callid = c.callid
				INNER JOIN callholder_GIT.dbo.vw_git_call_data_quick_2014_Audio a ON a.frn_callid = c.callid
				INNER JOIN callholder_GIT.dbo.vw_git_call_data_quick_2014_Details d ON d.frn_callid = c.callid
				INNER JOIN callholder_GIT.dbo.calllog_ani ani ON ani.calllog_aniid = c.frn_calllog_aniid
				INNER JOIN callholder_GIT.dbo._git_call_datadisposition disp ON disp._git_call_datadispositionid = c.frn__git_call_datadispositionid
				INNER JOIN callholder_GIT.dbo.xgit_phoneLINES_label label0 ON label0.frn_git_phoneLINESid = c.cf_frn_git_phoneLINESid AND label0.label_place=0
				INNER JOIN callholder_GIT.dbo.xgit_phoneLINES_label label1 ON label1.frn_git_phoneLINESid = c.cf_frn_git_phoneLINESid AND label1.label_place=1
				LEFT JOIN callholder_GIT.dbo.xgit_phoneLINES_label bridgeValue ON bridgeValue.frn_git_phoneLINESid = c.extension_frn_git_phoneLINESid AND bridgeValue.label_place=-1
				LEFT JOIN callholder_GIT.dbo.phonecode pc ON c.frn_phonecodeid = pc.phonecodeid
			WHERE
				GIT.GIT_reportid = #arguments.GIT_reportID#
         </cfquery> --->

         <cfreturn QueryToArrayOfStructures(theQuery)>
    </cffunction>

    <cfscript>
		function QueryToArrayOfStructures(theQuery){
			var theArray = arraynew(1);
			var cols = ListtoArray(theQuery.columnlist);
			var row = 1;
			var thisRow = "";
			var col = 1;
			for(row = 1; row LTE theQuery.recordcount; row = row + 1){
				thisRow = structnew();
				for(col = 1; col LTE arraylen(cols); col = col + 1){
					thisRow[cols[col]] = theQuery[cols[col]][row];
				}
				arrayAppend(theArray,duplicate(thisRow));
			}
			return(theArray);
		}

		function QueryToStruct(query,row){	/*returns the row FROM a query in struct format*/
			var LOCAL = StructNew();
			if (ARGUMENTS.Row){
				LOCAL.FromIndex = ARGUMENTS.Row;
				LOCAL.ToIndex = ARGUMENTS.Row;
			} else {
				LOCAL.FromIndex = 1;
				LOCAL.ToIndex = ARGUMENTS.Query.RecordCount;
			}
			LOCAL.Columns = ListToArray( ARGUMENTS.Query.ColumnList );
			LOCAL.ColumnCount = ArrayLen( LOCAL.Columns );
			LOCAL.DataArray = ArrayNew( 1 );
			for (LOCAL.RowIndex = LOCAL.FromIndex ; LOCAL.RowIndex LTE LOCAL.ToIndex ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
				ArrayAppend( LOCAL.DataArray, StructNew() );
				LOCAL.DataArrayIndex = ArrayLen( LOCAL.DataArray );
				for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE LOCAL.ColumnCount ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
					LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
					LOCAL.DataArray[ LOCAL.DataArrayIndex ][ LOCAL.ColumnName ] = ARGUMENTS.Query[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
				}
			}
			if (ARGUMENTS.Row){
				return( LOCAL.DataArray[ 1 ] );
			} else {
				return( LOCAL.DataArray );
			}
		}
	</cfscript>
 </cfcomponent>