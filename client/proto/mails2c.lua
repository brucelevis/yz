return {
	p = "mail",
	si = 2000, -- [2000,2500)
	src = [[

mail_syncmail 2000 {
	request {
		base 0 : basetype
		mail 1 : MailType
	}
}

mail_allmail 2001 {
	request {
		base 0 : basetype
		mails 1 : *MailType
	}
}

mail_delmail_result 2002 {
	request {
		base 0 : basetype
		result 1 : boolean
	}
}
]]
}
