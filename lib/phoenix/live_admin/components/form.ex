defmodule Phoenix.LiveAdmin.Components.Resource.Form do
  use Phoenix.Component
  use Phoenix.HTML

  import Phoenix.LiveAdmin.ErrorHelpers
  import Phoenix.LiveAdmin.Components.Resource, only: [fields: 1]

  def render(assigns) do
    %resource{} = assigns.changeset.data
    assigns = assign(assigns, :resource, resource)

    ~H"""
    <%= form_for @changeset, "#", [as: "params", phx_change: "validate", phx_submit: "save", class: "w-3/4 shadow-md p-2"], fn f -> %>
      <%= for {field, type} <- fields(@resource) do %>
        <.field field={field} type={type} form={f} />
      <% end %>
      <div class="text-right">
        <%= submit "Save", class: "inline-flex items-center h-8 px-4 m-2 text-sm text-indigo-100 transition-colors duration-150 bg-indigo-700 rounded-lg focus:shadow-outline hover:bg-indigo-800" %>
      </div>
    <% end %>
    """
  end

  def field(assigns = %{type: type}) when type in [:string, :integer] do
    ~H"""
    <div class="flex flex-col mb-4">
      <%= label @form, @field, class: "mb-2 uppercase font-bold text-lg text-grey-darkest" %>
      <%= text_input @form, @field, class: "border py-2 px-3 text-grey-darkest"  %>
      <%= error_tag @form, @field %>
    </div>
    """
  end

  def field(assigns = %{type: {_, Ecto.Embedded, %{related: schema}}}) do
    assigns = assign(assigns, :embed_fields, fields(schema))

    ~H"""
    <div>
      <h2 class="mb-2 uppercase font-bold text-lg text-grey-darkest"><%= @field %></h2>
      <div class="flex flex-col mb-4 ml-4">
        <%= inputs_for @form, @field, fn fp -> %>
          <%= for {field, type} <- @embed_fields do %>
            <.field field={field} type={type} form={fp} />
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def field(assigns), do: ~H""
end