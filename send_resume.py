import smtplib
import pandas as pd
from email.message import EmailMessage

# Gmail credentials
EMAIL_ADDRESS = "dgulladurthi@gmail.com"
EMAIL_PASSWORD = "jpjsjasdzk"
## https://myaccount.google.com/apppasswords?pli=1&rapt=AEjHL4MvdvXHXmKNBGmutNdE6yKzersq7z0e17_sBzfBf_aL2fHX-2o8z4HUO7Re2-qDXCKR6A-VkMv-sedP_o7r7XsZDEhG7gmWQVovLvVc_5sroJ0w440

# Read CSV
df = pd.read_csv("hr_emails.csv")

# Read HTML email template
with open("email_template.html", "r") as f:
    template = f.read()

# SMTP Server
server = smtplib.SMTP_SSL("smtp.gmail.com", 465)
server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)

for index, row in df.iterrows():
    msg = EmailMessage()

    # Replace placeholders in HTML template
    html_content = template.format(
        name=row["name"],
        company=row["company"]
    )

    # Email headers
    msg["Subject"] = f"Application for DevOps Engineer Role at {row['company']}"
    msg["From"] = EMAIL_ADDRESS
    msg["To"] = row["email"]

    # ✅ Plain-text fallback (VERY IMPORTANT)
    msg.set_content(
        "Hi,\n\n"
        "Please view this email in HTML format to see the complete message.\n\n"
        "Regards,\n"
        "Divya"
    )

    # ✅ HTML version (shown by Gmail)
    msg.add_alternative(html_content, subtype="html")

    # Attach Resume
    with open("/opt/email_automation/Divya_DevOps_Resume.pdf", "rb") as resume:
        msg.add_attachment(
            resume.read(),
            maintype="application",
            subtype="pdf",
            filename="Divya_DevOps_Resume.pdf"
        )

    server.send_message(msg)
    print(f"Email sent to {row['email']}")

server.quit()
