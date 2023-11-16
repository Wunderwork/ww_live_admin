defmodule LiveAdmin.Components.Container.View do
  use Phoenix.LiveComponent
  use Phoenix.HTML

  import LiveAdmin, only: [route_with_params: 2, trans: 1]
  import LiveAdmin.View, only: [field_class: 1]

  alias LiveAdmin.Resource
  alias Phoenix.LiveView.JS

  @impl true
  def render(assigns = %{record: nil}) do
    ~H"""
    <div><%= trans("No record found") %></div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="resource__view">
      <div class="resource__table">
        <dl>
          <%= for {field, type, _} <- Resource.fields(@resource) do %>
            <% assoc_resource =
              LiveAdmin.associated_resource(
                @resource.__live_admin_config__(:schema),
                field,
                @resources
              ) %>
            <% label = Resource.render(@record, field, @resource, assoc_resource, @session) %>
            <dt class="field__label"><%= trans(humanize(field)) %></dt>
            <dd class={"field__#{field_class(type)}"}>
              <%= if assoc_resource && Map.fetch!(@record, field) do %>
                <.link
                  patch={
                    route_with_params(assigns,
                      resource_path: elem(assoc_resource, 0),
                      segments: [Map.fetch!(@record, field)]
                    )
                  }
                  class="resource__action--btn"
                >
                  <%= label %>
                </.link>
              <% else %>
                <%= label %>
              <% end %>
            </dd>
          <% end %>
        </dl>
        <div class="form__actions">
          <.link
            navigate={route_with_params(assigns, segments: [:edit, @record])}
            class="resource__action--btn"
          >
            <%= trans("Edit") %>
          </.link>
          <%= if @resource.__live_admin_config__(:delete_with) != false do %>
            <button
              class="resource__action--danger"
              data-confirm="Are you sure?"
              phx-click={JS.push("delete", value: %{id: @record.id}, page_loading: true)}
            >
              <%= trans("Delete") %>
            </button>
          <% end %>
          <div class="resource__action--drop">
            <button
              class={"resource__action#{if Enum.empty?(@resource.__live_admin_config__(:actions)), do: "--disabled", else: "--btn"}"}
              disabled={if Enum.empty?(@resource.__live_admin_config__(:actions)), do: "disabled"}
            >
              <%= trans("Run action") %>
            </button>
            <nav>
              <ul>
                <%= for action <- @resource.__live_admin_config__(:actions) do %>
                  <li>
                    <button
                      class="resource__action--link"
                      data-confirm="Are you sure?"
                      phx-click={
                        JS.push("action",
                          value: %{id: @record.id, action: action},
                          page_loading: true
                        )
                      }
                    >
                      <%= action |> to_string() |> humanize() %>
                    </button>
                  </li>
                <% end %>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
