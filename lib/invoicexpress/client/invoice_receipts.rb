require 'invoicexpress/models'

module Invoicexpress
  class Client
    module InvoiceReceipts

      # Returns all your invoice-receipts
      #
      # @option options [Integer] page (1) You can ask a specific page of invoice-receipts
      #
      # @return [Array<Invoicexpress::Models::Invoice>] An array with all your invoice-receipts
      # @raise Invoicexpress::Unauthorized When the client is unauthorized
      def invoice_receipts(options={})
        params = { :page => 1, :klass => Invoicexpress::Models::InvoiceReceipts }

        get("invoice_receipts.xml", params.merge(options))
      end

      # Returns a specific invoice-receipt
      #
      # @param invoice_receipt_id [String] Requested invoice-receipt id
      # @return [Invoicexpress::Models::Invoice] The requested invoice-receipt
      # @raise Invoicexpress::Unauthorized When the client is unauthorized
      # @raise Invoicexpress::NotFound When the invoice doesn't exist
      def invoice_receipt(invoice_receipt_id, options={})
        params = { :klass => Invoicexpress::Models::InvoiceReceipt }

        get("invoice_receipts/#{invoice_receipt_id}.xml", params.merge(options))
      end

      # Creates a new invoice-receipt. Also allows to create a new client and/or new items in the same request.
      # If the client name does not exist a new one is created.
      # If items do not exist with the given names, new ones will be created.
      # If item name  already exists, the item is updated with the new values.
      # Regarding item taxes, if the tax name is not found, no tax is applyed to that item.
      # Portuguese accounts should also send the IVA exemption reason if the invoice contains exempt items(IVA 0%)
      #
      # @param invoice_receipt [Invoicexpress::Models::Invoice] The invoice-receipt to create
      # @return [Invoicexpress::Models::Invoice] The created invoice-receipt
      # @raise Invoicexpress::Unauthorized When the client is unauthorized
      # @raise Invoicexpress::UnprocessableEntity When there are errors on the submission
      def create_invoice_receipt(invoice_receipt, options={})
        raise(ArgumentError, "invoice-receipt has the wrong type") unless invoice_receipt.is_a?(Invoicexpress::Models::InvoiceReceipt)

        params = { :klass => Invoicexpress::Models::InvoiceReceipt, :body  => invoice_receipt }
        post("invoice_receipts.xml", params.merge(options))
      end

      # Updates an invoice-receipt
      # It also allows you to create a new client and/or items in the same request.
      # If the client name does not exist a new client is created.
      # Regarding item taxes, if the tax name is not found, no tax will be applied to that item.
      # If item does not exist with the given name, a new one will be created.
      # If item exists it will be updated with the new values
      # Be careful when updating the document items, any missing items from the original document will be deleted.
      #
      # @param invoice_receipt [Invoicexpress::Models::Invoice] The invoice-receipt to update
      # @raise Invoicexpress::Unauthorized When the client is unauthorized
      # @raise Invoicexpress::UnprocessableEntity When there are errors on the submission
      # @raise Invoicexpress::NotFound When the invoice-receipt doesn't exist
      def update_invoice_receipt(invoice_receipt, options={})
        raise(ArgumentError, "invoice-receipt has the wrong type") unless invoice_receipt.is_a?(Invoicexpress::Models::InvoiceReceipt)

        params = { :klass => Invoicexpress::Models::InvoiceReceipt, :body  => invoice_receipt.to_core }
        put("invoice_receipts/#{invoice_receipt.id}.xml", params.merge(options))
      end

      # Changes the state of an invoice-receipt.
      # Possible state transitions:
      # - draft to settled – finalized
      # - draft to delete – deleted
      # - settled to canceled – canceled
      # Any other transitions will fail.
      # When canceling an invoice-receipt you must specify a reason.
      #
      # @param invoice_receipt_id [String] The invoice-receipt id to change
      # @param invoice_state [Invoicexpress::Models::InvoiceState] The new state
      # @return [Invoicexpress::Models::Invoice] The updated invoice
      # @raise Invoicexpress::Unauthorized When the client is unauthorized
      # @raise Invoicexpress::UnprocessableEntity When there are errors on the submission
      # @raise Invoicexpress::NotFound When the invoice doesn't exist
      def update_invoice_state(invoice_receipt_id, invoice_state, options={})
        raise(ArgumentError, "invoice_state has the wrong type") unless invoice_state.is_a?(Invoicexpress::Models::InvoiceState)

        params = { :klass => Invoicexpress::Models::InvoiceReceipt, :body => invoice_state }
        put("invoice_receipts/#{invoice_receipt_id}/change-state.xml", params.merge(options))
      end

      # Sends the invoice-receipt by email
      #
      # @param invoice_receipt_id [String] The invoice-receipt id to change
      # @param message [Invoicexpress::Models::Message] The message to send
      # @raise Invoicexpress::Unauthorized When the client is unauthorized
      # @raise Invoicexpress::UnprocessableEntity When there are errors on the submission
      # @raise Invoicexpress::NotFound When the invoice-receipt doesn't exist
      def email_invoice_receipt(invoice_receipt_id, message, options={})
        raise(ArgumentError, "message has the wrong type") unless message.is_a?(Invoicexpress::Models::Message)

        params = { :body => message, :klass => Invoicexpress::Models::InvoiceReceipt }
        put("invoice_receipts/#{invoice_receipt_id}/email-document.xml", params.merge(options))
      end
    end
  end
end
