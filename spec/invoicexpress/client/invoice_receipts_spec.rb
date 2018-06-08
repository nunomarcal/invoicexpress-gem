require 'helper'

describe Invoicexpress::Client::InvoiceReceipts do
  before do
    @client = Invoicexpress::Client.new(:account_name => "thinkorangeteste")
  end

  describe ".invoice_receipts" do
    it "Returns all the invoice-receipts" do
      stub_get("/invoice_receipts.xml?page=1").
        to_return(xml_response("invoice_receipts.list.xml"))

      items = @client.invoice_receipts
      items.invoice_receipts.count.should == 10
      items.current_page == 1
    end
  end

  describe ".create_invoice_receipt" do
    it "creates a new invoice-receipt" do
      stub_post("/invoice_receipts.xml").
        to_return(xml_response("invoices.create.xml"))


      object = Invoicexpress::Models::InvoiceReceipt.new(
        :date => Date.new(2013, 6, 18),
        :due_date => Date.new(2013, 6, 18),
        :tax_exemption => "M01",
        :client => Invoicexpress::Models::Client.new(
          :name => "Nuno Miguel"
        ),
        :items => [
          Invoicexpress::Models::Item.new(
            :name => "Item 1",
            :unit_price => 30,
            :quantity => 1,
            :unit => "unit",
          )
        ]
      )

      item = @client.create_invoice_receipt(object)
      item.id.should        == 1503698
      item.status           == "draft"
    end

    context 'given an invoice-receipt with mb_reference set to true' do
      let (:invoice_receipt) do
        Invoicexpress::Models::InvoiceReceipt.new(
          :date => Date.new(2013, 6, 18),
          :due_date => Date.new(2013, 6, 18),
          :tax_exemption => "M01",
          :mb_reference => true,
          :client => Invoicexpress::Models::Client.new(
            :name => "Nuno Miguel"
          ),
          :items => [
            Invoicexpress::Models::Item.new(
              :name => "Item 1",
              :unit_price => 30,
              :quantity => 1,
              :unit => "unit",
            )
          ]
        )
      end

      before do
        stub_post("/invoice_receipts.xml").
          to_return(xml_response("invoices.create.xml"))
      end

      it 'creates a draft invoice-receipt' do
        item = @client.create_invoice(invoice)
        item.id.should        == 1503698
        item.status           == "draft"
      end

      it 'sends mb_reference only once in the payload' do
        @client.create_invoice(invoice_receipt)
        expect(a_request(:post, /.+invoice_receipts.xml$/).with do |req|
          req.body.scan(/<mb_reference>true<\/mb_reference>/).length == 1
        end).to have_been_made.once
      end
    end
  end

  describe ".invoice_receipt" do
    it "gets a invoice-receipt" do
      stub_get("/invoice_receipts/1503698.xml").
        to_return(xml_response("invoices.get.xml"))

      item = @client.invoice(1503698)
      item.status.should == "draft"
      item.client.id.should == 501854
    end
  end

  describe ".update_invoice_receipt" do
    it "updates the invoice-receipt" do
      stub_put("/invoice_receipts/1503698.xml").
        to_return(xml_response("ok.xml"))

      model = Invoicexpress::Models::InvoiceReceipt.new(:id => 1503698)
      expect { @client.update_invoice_receipt(model) }.to_not raise_error
    end

    it "raises if no invoice-receipt is passed" do
      expect {
        @client.update_invoice_receipt(nil)
      }.to raise_error(ArgumentError)
    end
  end

  describe ".update_invoice_receipt_state" do
    it "updates the state" do
      stub_put("/invoice_receipts/1503698/change-state.xml").
        to_return(xml_response("invoices.update_state.xml"))

      state = Invoicexpress::Models::InvoiceState.new(
        :state => "finalized"
      )
      expect { @client.update_invoice_state(1503698, state) }.to_not raise_error
    end
  end

  describe ".email_invoice_receipt" do
    it "sends the invoice-receipt through email" do
      stub_put("/invoice_receipts/1503698/email-document.xml").
        to_return(xml_response("ok.xml"))
      message = Invoicexpress::Models::Message.new(
        :subject => "Hello world",
        :body => "Here is the invoice.",
        :client => Invoicexpress::Models::Client.new(
          :name => "Nuno Miguel",
          :email=> 'nuno.marcal@blackorange.pt'
        )
      )
      expect { @client.email_invoice(1503698, message) }.to_not raise_error
    end
  end
end
