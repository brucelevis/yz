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
		mails 1 : *MailType			#空/空列表--清空所有邮件
	}
}

mail_delmail 2002 {
	request {
		base 0 : basetype
		mailid 1 : integer
	}
}

mail_updatemail 2003 {
	request {
		base 0 : basetype
		mail 1 : MailType
	}
}
]]
}
