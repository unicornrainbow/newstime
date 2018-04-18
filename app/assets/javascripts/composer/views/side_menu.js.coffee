
App = Dreamtool

class SideMenu extends App.View

  className: 'side-menu'

  template: """
    <li>Edition Settings</li>
    <div class="edition-settings">
      <li>Page Width</li>
    </div>
    <div class="page-width">
      <li>240px</li>
      <li>480px</li>
      <li>960px</li>
      <li>1040px</li>
    </div>
  """

  initialize: ->
    @$html @template



class TimeMachine

  initialize: ->
    @model.set 'year', 2018


App.SideMenu = SideMenu
