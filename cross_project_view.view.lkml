view: cross_project_view {

  derived_table: {
    sql: SELECT *
      FROM demo_db.users ;;
  }

dimension: age {
  type: number
  sql: ${TABLE}.age ;;
}


  }
