<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

<% unless options[:singleton] -%>
  def index
    authorize <%= controller_class_name.singularize %>

    <%= plural_table_name %> = <%= class_name %>.all
    <%= plural_table_name %> = <%= plural_table_name %>.search(params[:filter]) if params[:filter]
    @<%= plural_table_name %> = smart_listing_create(:<%= plural_table_name %>,
                                    <%= plural_table_name %>,
                                    partial: "<%= plural_table_name %>/list")
  end
<% end -%>

  def show
    authorize <%= controller_class_name.singularize %>
    # limit audits selection
    audit = nil
    audit = Audit.where(auditable_id: @<%= singular_table_name %>.id, auditable_type: '<%= controller_class_name.singularize %>') if @<%= singular_table_name %>.id.present?
    # nested view: skip smartlist filter, page size set to high number,
    # default sorting is by id, for best (<1s) resolution
    @audits = smart_listing_create(:audits, audit, partial: "audits/list", default_sort: { id: "desc" }, page_sizes: [1_000_000])

  end

  def new
    authorize <%= controller_class_name.singularize %>
    @<%= singular_table_name %> = <%= class_name %>.new
  end

  def edit
    authorize <%= controller_class_name.singularize %>
  end

  def create
    authorize <%= controller_class_name.singularize %>

    @<%= singular_table_name %> = <%= class_name %>.new(<%= singular_table_name %>_params)

    respond_to do |format|
      if @<%= singular_table_name %>.save
        format.html { redirect_to @<%= singular_table_name %>, notice: '<%= table_name.singularize.humanize.titleize %>  was successfully created.' }
        format.json { render :show, status: :created, location: @<%= singular_table_name %> }
      else
        format.html { render :new }
        format.json { render json: @<%= singular_table_name %>.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize <%= controller_class_name.singularize %>
    respond_to do |format|
      if @<%= singular_table_name %>.update(<%= singular_table_name %>_params)
        format.html { redirect_to @<%= singular_table_name %>, notice: '<%= table_name.singularize.humanize.titleize %>  was successfully updated.' }
        format.json { render :show, status: :ok, location: @<%= singular_table_name %> }
      else
        format.html { render :edit }
        format.json { render json: @<%= singular_table_name %>.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize <%= controller_class_name.singularize %>
    # update audit comment before destroy
    add_audit_comment(@<%= singular_table_name %>)
    @<%= singular_table_name %>.destroy

    respond_to do |format|
      format.html { redirect_to <%= plural_table_name %>_url, notice: '<%= table_name.singularize.humanize.titleize %>  was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= class_name %>.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[:<%= singular_table_name %>]
      <%- else -%>
      params.require(:<%= singular_table_name %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>, :audit_comment)
      <%- end -%>
    end
end
<% end -%>

