# Command for building a lab

## Notes for things to remember

+ Set a GPO up for high preformance

    1. Open Group Policy Management Console. You can do this by typing gpmc.msc in the Run dialog (Win + R).

    2. In the GPMC, go to "Group Policy Objects", right click and select "New" to create a new GPO.

    3. Give the GPO a name, like "High Performance Power Plan".

    4. Right click on the newly created GPO and select "Edit". This will open the Group Policy Management Editor.

    5. In the editor, navigate to "Computer Configuration" -> "Preferences" -> "Control Panel Settings" -> "Power Options".

    6. Right click on "Power Options" and select "New" -> "Power Plan (At least Windows 7)".

    7. In the new window, select "High performance" for the "Power Plan" dropdown.

    8. Click "OK" to close the window.

    9. Close the Group Policy Management Editor.

    10. Back in the GPMC, link the GPO to the appropriate Organizational Unit (OU) that contains the computers you want this policy to apply to.