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

## linux commands
If you want to generate a sequence of strings like "dev01", "dev02", "dev03", ..., you can use a combination of the `printf` and `seq` commands in Ubuntu. Here's how you can do it:

```bash
printf "dev%02d " $(seq 1 10)
```

In this command, `seq 1 10` generates a sequence of numbers from 1 to 10. The `printf "dev%02d "` command formats each number as a two-digit number prefixed with "dev". The `%02d` in the format string is a placeholder that gets replaced with each number in the sequence. The `02` means that the number should be two digits long, and leading zeros should be used if the number is less than two digits long.

This command will output:

```
dev01 dev02 dev03 dev04 dev05 dev06 dev07 dev08 dev09 dev10
```

You can replace `10` with any number to generate a sequence of that length.
