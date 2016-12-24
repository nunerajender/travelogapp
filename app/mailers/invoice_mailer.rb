class InvoiceMailer < ActionMailer::Base
	default from: "Travelog <support@travelog.com>"
	include ApplicationHelper
	
	def checkout(invoice, user_type)
		@invoice = invoice
		@currency_symbols = get_all_currency_symbols
		
		attachments["receipt.pdf"] = WickedPdf.new.pdf_from_string(
			render_to_string(pdf: 'receipt', template: 'invoice_mailer/checkout.html.erb')
		)
		if user_type == 1
			mail(:to => invoice.contact_detail.email, :subject => "Receipt the travel on Travelog")
		elsif user_type == 2
			mail(:to => invoice.product.user.email, :subject => "Receipt the travel on Travelog")
		elsif user_type == 3
			mail(:to => "no-reply@travelog.com", :subject => "Receipt the travel on Travelog")
		end
		
	end

end