# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class Seeds
  def initialize
    base_seeds!
    run_env_seeds!
  end

  private

  def run_env_seeds!
    seeder = "#{Rails.env}_seeds!"
    if respond_to?(seeder.to_sym, true)
      send(seeder)
    else
      log "Seeds for #{Rails.env} not defined, skipping.", level: :warn
    end
  end

  def base_seeds!
    # Set up user roles
    Role.create!(name: "admin", friendly_name: "Admin")
    Role.create!(name: "manager", friendly_name: "Manager")
    Role.create!(name: "analyst", friendly_name: "Analyst")

    # set up Actor Types with taxonomies ########################################################
    # 1 Countries
    countries = Actortype.create!(
      title: "Country",
      has_members: true
    )

    # 2 Organisations
    orgs = Actortype.create!(
      title: "Organisation",
      has_members: true
    )

    # 3 Contacts (external)
    contacts = Actortype.create!(
      title: "Contacts"
    )

    # 4 Regions
    regions = Actortype.create!(
      title: "Region",
      has_members: true
    )

    # 5 Groups
    groups = Actortype.create!(
      title: "Group",
      has_members: true
    )

    # set up Activity Types with taxonomies ########################################################
    # 1 Expressions
    expressions = Measuretype.create!(
      title: "Expression"
      # has_indicators: true,
    )

    # 2 Events
    events = Measuretype.create!(
      title: "Event"
    )

    # 3 Outreach plans
    outreachplans = Measuretype.create!(
      title: "Outreach plan"
    )

    # 4 Advocacy plans
    advocacyplans = Measuretype.create!(
      title: "Advocacy plan"
    )

    # 5 Tasks (outreach, advocacy?)
    tasks = Measuretype.create!(
      title: "Task"
    )

    # 6 Interactions
    interactions = Measuretype.create!(
      title: "Interaction"
    )

    # Set up taxonomies ########################################################
    # 1 Country status
    countrystatus = Taxonomy.create!(
      title: "Country status",
      allow_multiple: false
    )
    ActortypeTaxonomy.create!(
      taxonomy: countrystatus,
      actortype: countries
    )
    # 2 Organisation sector
    orgsector = Taxonomy.create!(
      title: "Sector",
      allow_multiple: false
    )
    ActortypeTaxonomy.create!(
      taxonomy: orgsector,
      actortype: orgs
    )
    # 3 Contact type aka "role"
    contacttype = Taxonomy.create!(
      title: "Role",
      allow_multiple: true
    )
    ActortypeTaxonomy.create!(
      taxonomy: contacttype,
      actortype: contacts
    )
    # 4 Type of region
    regiontype = Taxonomy.create!(
      title: "Region type",
      allow_multiple: true
    )
    ActortypeTaxonomy.create!(
      taxonomy: regiontype,
      actortype: regions
    )
    # 5 type of group
    grouptype = Taxonomy.create!(
      title: "Type of group",
      allow_multiple: false
    )
    ActortypeTaxonomy.create!(
      taxonomy: grouptype,
      actortype: groups
    )
    # 6 level of support
    supportlevel = Taxonomy.create!(
      title: "Level of support",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: supportlevel,
      measuretype: expressions
    )
    # 7 type of expression
    expressiontype = Taxonomy.create!(
      title: "Form of expression",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: expressiontype,
      measuretype: expressions
    )
    # 8 tags (buzzwords)
    tags = Taxonomy.create!(
      title: "Tags",
      allow_multiple: true
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: tags,
      measuretype: expressions
    )
    # 9 type of event
    eventtype = Taxonomy.create!(
      title: "Type of event",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: eventtype,
      measuretype: events
    )
    # 10 priority of plan
    priority = Taxonomy.create!(
      title: "Priority",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: priority,
      measuretype: outreachplans
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: priority,
      measuretype: advocacyplans
    )
    # 11 task status
    status = Taxonomy.create!(
      title: "Status",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: status,
      measuretype: tasks
    )
    # 12 interaction type
    interactiontype = Taxonomy.create!(
      title: "Type of interaction",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: interactiontype,
      measuretype: interactions
    )

    # Set up categories ########################################################
    # Convention status
    # convstatus.categories.create!(title: "Signed")

    # Group type taxonomy
    grouptype.categories.create!(title: "Intergovernmental")
    grouptype.categories.create!(title: "Mixed")

    # Org sector taxonomy
    orgsector.categories.create!(title: "Civil society")
    orgsector.categories.create!(title: "Private sector")
    orgsector.categories.create!(title: "Science & research")
    orgsector.categories.create!(title: "Public sector")

    # country status taxonomy
    countrystatus.categories.create!(title: "Country")
    countrystatus.categories.create!(title: "Dependency")
    countrystatus.categories.create!(title: "Disputed")
    countrystatus.categories.create!(title: "Indeterminate")
    countrystatus.categories.create!(title: "Sovereign country")

  end

  def development_seeds!
    return unless User.count.zero?
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
