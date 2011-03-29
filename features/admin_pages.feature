Feature: Admin Pages Management Features

@index_page_view
Scenario: Navigate to the Pages#index page
  Given I login as "ak730" with the role of "admin"
  And these pages exist with current state
  | title  | status    |
  | foobar | published |
  | bar    | draft     |
  When I go to the admin pages page
  Then I should be on the admin pages page
  And I should see "foobar" within "tr#foobar"
  And I should see "published" within "tr#foobar"
  And I should see "delete" button within "tr#foobar"
  And I should see "bar" within "tr#bar"
  And I should see "draft" within "tr#bar"
  And I should see "delete" button within "tr#bar"
  And I should see "Add New Page"
  
@create_new_page_root_page
Scenario: Create a new page
  Given I login as "ak730" with the role of "admin"
  And the user with the role exist
  | user   | role   |
  | foo    | admin  |
  | bar    | editor |
  | foobar | editor |
  And these current states exist
  | name      |
  | published |
  | draft     |
  And these layouts exist
  | name | content              |
  | app  | Hello, World         |
  | baz  | Hello, <b>World!</b> |
  When I go to the admin pages page
  And I follow "Add New Page"
  Then I should be on the new admin page page
  And I select "normal" from "page_page_type_attributes_id" within "div#add_new_page"
  And I fill in "page_title" with "foobar" within "div#add_new_page"
  And I fill in "page_meta_title" with "meta_title_foobar" within "div#add_new_page"
  And I fill in "page_meta_keywords" with "meta_keywords_foobar" within "div#add_new_page"
  And I fill in "page_meta_description" with "meta_description_foobar" within "div#add_new_page"
  And I check "editor_id_ak730" within "div#add_new_page"
  And I check "editor_id_foo" within "div#add_new_page"
  And I select "app" from "page_layout_id" within "div#add_new_page"
  And I select "haml" from "page_filter" within "div#add_new_page"
  And I select "published" from "page_current_state_attributes_id" within "div#add_new_page"
  And I fill in "page_page_parts_attributes_0_name" with "content" within "div#add_new_page"
  And I fill in "page_page_parts_attributes_0_content" with "Hello, World!" within "div#add_new_page"
  And I press "Create Page" within "div#add_new_page"
  Then I should be on the admin pages page
  And I should see "Successfully created page foobar"
  And I should see "foobar" within "tr#foobar"
  And I should see "published" within "tr#foobar"
  And I should see "delete" button within "tr#foobar"