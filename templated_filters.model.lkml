connection: "thelook"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project


explore: fruit_table {
  hidden: no
}
view: fruit_table {
  derived_table: {
    persist_for: "1 hour"
    sql:
    (select 'apple' as category, 1.2 as price, 15 as quantity, timestamp('2017-01-01') as stock_date) union all
    (select 'pear' as category, 1.5 as price, 10 as quantity, timestamp('2017-01-01') as stock_date) union all
    (select 'peach' as category, 1.0 as price, 5 as quantity, timestamp('2017-01-01') as stock_date) union all
    (select 'blueberries' as category, 2.75 as price, 2 as quantity, timestamp('2017-01-01') as stock_date) union all
    (select 'plum' as category, 0.9 as price, 7 as quantity, timestamp('2017-01-01') as stock_date) union all
    (select 'banana' as category, 0.3 as price, 4 as quantity, timestamp('2017-01-01') as stock_date) union all
    (select 'strawberries' as category, 3.10 as price, 3 as quantity, timestamp('2017-01-01') as stock_date) union all
    (select 'apple' as category, 1.3 as price, 15 as quantity,  timestamp('2017-02-01') as stock_date) union all
    (select 'pear' as category, 1.2 as price, 10 as quantity, timestamp('2017-02-01') as stock_date) union all
    (select 'peach' as category, 1.1 as price, 5 as quantity, timestamp('2017-02-01') as stock_date) union all
    (select 'blueberries' as category, 2.56  as price, 2 as quantity, timestamp('2017-02-01') as stock_date) union all
    (select 'plum' as category, 0.7 as price, 7 as quantity,  timestamp('2017-02-01') as stock_date) union all
    (select 'banana' as category, 0.25 as price, 4 as quantity, timestamp('2017-02-01') as stock_date)

    ;;
  }




  dimension: comparator {
    type: string
    sql:
    case when {% condition fruit_filter %} ${category} {% endcondition %}
    then ${category}
    else 'Rest of population'
    end
    ;;
  }
  filter: fruit_filter {
    suggestions: ["apple", "pear", "peach","blueberries","plum","banana","starberries"]
    type: string


  }
  dimension: stock_date {
    type: date
    allow_fill: no
    convert_tz: no
  }
  dimension: category {
    type: string
  }

  measure: percentile_50 {
    type: percentile
    percentile: 50
    sql: ${TABLE}.price ;;
  }


  measure: avg_price {
    type: average
    sql: ${TABLE}.price ;;
    value_format_name: usd
  }
}


explore: templated_filter_ex  {
  hidden: yes
  join: fruit_table {
    sql_on: ${fruit_table.stock_date}=${templated_filter_ex.stock_check_date} and ${fruit_table.category}=${templated_filter_ex.category} ;;
  }
}
view: templated_filter_ex {
  derived_table: {
    sql:
      select
      category,
      row_number() over (partition by stock_date order by price * quantity desc) rank_stock_price,
      price*quantity stock_price,
      stock_date as stock_check_date

      from ${fruit_table.SQL_TABLE_NAME} as fruit
      where {% condition fruit_table.fruit_filter %} category {% endcondition %}
       and {% condition date_filter %} ${stock_check_date} {% endcondition %}

          ;;
  }


  dimension: category{}
  dimension: stock_check_date {
    type: date
    allow_fill: no
    convert_tz: no
  }
  filter: date_filter {
    type: date
    convert_tz: no
  }
  dimension: rank_stock_price {
    type: number
  }
  dimension: stock_price {
    type: number
    value_format_name: usd
  }
  dimension: is_berry {
    type: string
    sql: case when {% condition fruit_table.fruit_filter %} ${category} {% endcondition %} in ('strawberries', 'blueberries')
          then 'berry'
          else 'not berry'
          end ;;

    }





    measure: count {}
    measure: avg_stock_price {
      type: average
      sql: ${stock_price} ;;
    }

  }
