// add another creator section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.add_creator', function(event) {
    event.preventDefault();

    // find the nearest parent creator section and clone it
    // then clear the values in the fields in that section
    const ubiquityCreatorClass = $(this).attr('data-addUbiquityCreator');
    const clonedCreatorSection = $(this).closest(`div${ubiquityCreatorClass}`).last().clone();
    clonedCreatorSection.find('input').val('');
    clonedCreatorSection.find('option').attr('selected', false);

    // increment hidden_field counter after cloning
    const lastInputCount = $('.ubiquity-creator-score').last().val();
    const hiddenInput = $(clonedCreatorSection).find('.ubiquity-creator-score');
    hiddenInput.val(parseInt(lastInputCount) + 1);

    // add the cloned section at the end of the creator list
    // and set 'Personal' as the type
    $(`${ubiquityCreatorClass}`).last().after(clonedCreatorSection);
    $('.ubiquity_creator_name_type').last().val('Personal').change();
  });
});

// remove selected creator section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.remove_creator', function(event) {
    event.preventDefault();

    if ($('.ubiquity-meta-creator').length > 1 ) {
      const ubiquityCreatorClass = $(this).attr('data-removeUbiquityCreator');
      $(this).closest(`div${ubiquityCreatorClass}`).remove();
    }
  });
});

// display a new creator section on the new or edit form
$(document).on('turbolinks:load', function() {
  return $('body').on('change', '.ubiquity_creator_name_type', function() {
    displayCreatorFields($(this.parentElement), this.value);
  });
});

// set saved values in the creator section(s) on the edit work form
$(document).on('turbolinks:load', function() {
  $('.ubiquity_creator_name_type').each(function() {
    displayCreatorFields($(this).parent(), this.value);
  })
});

function displayCreatorFields(self, value) {
  if (value == 'Personal') {
    const lastPersonalSibling = self.siblings('.ubiquity_personal_fields').last();

    hideCreatorOrganization(self);
    creatorUpdateRequired(lastPersonalSibling, 'family');
    creatorUpdateRequired(lastPersonalSibling, 'given');

  } else if (value == 'Organisational') {
    const lastOrgSibling = self.siblings('.ubiquity_organization_fields').last();

    hideCreatorPersonal(self);
    creatorUpdateRequired(lastOrgSibling, 'organization');

  } else {
    $('.ubiquity_creator_name_type').last().val('Personal').change();
  }
}

// update the org name
$(document).on('turbolinks:load', function() {
  return $('body').on('blur', '.ubiquity_creator_organization_name', function (event) {
    event.preventDefault();

    const _this = $(this).closet('.ubiquity_organization_fields').last();
    creatorUpdateRequired(_this, 'organization');
  });
});

// update the family or given name
$(document).on('turbolinks:load', function() {
  return $('body').on('blur', '.ubiquity_creator_family_name, .ubiquity_creator_given_name', function (event) {
    event.preventDefault();

    const _this = $(this).closest('.ubiquity_personal_fields').last()
    creatorUpdateRequired(_this, 'family');
    creatorUpdateRequired(_this, 'given');
  });
});

function creatorUpdateRequired(self, field) {
  const givenName = self.find('.ubiquity_creator_given_name').last().val();
  const familyName = self.find('.ubiquity_creator_family_name').last().val();

  if (givenName || familyName) {
    self.find(`.ubiquity_creator_${field}_name`).last().attr('required', false);
  } else {
    self.find(`.ubiquity_creator_${field}_name`).last().attr('required', true);
  }
}

function hideCreatorOrganization(self) {
  self.siblings('.ubiquity_personal_fields').show();
  self.siblings('.ubiquity_organization_fields').find('.ubiquity_creator_organization_name').last().val('');
  self.siblings('.isni_input_group').find('.ubiquity_creator_isni').last().val('');
  self.siblings('.ubiquity_organization_fields').find('.ubiquity_creator_organization_name').last().removeAttr('required');
  self.siblings('.ubiquity_organization_fields').hide();
}

function hideCreatorPersonal(self) {
  self.siblings('.ubiquity_organization_fields').show();
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_creator_family_name').last().val('').removeAttr('required');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_creator_given_name').last().val('').removeAttr('required');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_creator_orcid').last().val('');
  self.siblings('.isni_input_group').find('.ubiquity_creator_isni').last().val('');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_creator_institutional_relationship').last().val('');
  self.siblings('.ubiquity_personal_fields').hide();
}
