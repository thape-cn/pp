import * as React from 'react';
import { createPortal } from 'react-dom';
import {useSortBy, useExpanded, useTable} from 'react-table'
import {get, put} from '@rails/request.js'
import {currentPageJsonPath} from "./utils/url";
import {calibrationTableHeader, calibrationTableLabels, groupLevel, svgArrowFromTop, svgArrowFromBottom, prepareTableSubmitData} from "./utils/tableHeader";
import {EditableCell} from "./table/EditableCell";
import {NameCell} from "./table/NameCell";
import {OverallReview} from "./table/OverallReview";

const group_level = groupLevel();

function CalibratioTable() {
  const [company_evaluation_templates, setCompanyEvaluationTemplates] = React.useState({});
  const [raw_data, setData] = React.useState([]);

  React.useEffect(() => {
    get(currentPageJsonPath(group_level)).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          setCompanyEvaluationTemplates(result.company_evaluation_templates);
          setData(result.need_calibration_eucs);
        });
      }
    });
  }, []);

  const data = React.useMemo(
    () => raw_data,
    [raw_data]
  );

  const columns = React.useMemo(
    () => {
      const original_calibration_table_header = calibrationTableHeader();
      return [
      {
        Header: calibrationTableLabels().row_number,
        id: 'rowNumber',
        Cell: ({ row, rows }) => {
          const sortedRowIndex = rows.findIndex(sortedRow => sortedRow.id === row.id);
          return <div className="m-1 text-end">{sortedRowIndex + 1}</div>;
        },
      },
      {
        // Make an expander cell
        Header: () => "评论", // No header
        id: 'expander', // It needs an ID if no accessor
        Cell: ({ row }) => (
          // Use Cell to render an expander for each row.
          // We can use the getToggleRowExpandedProps prop-getter
          // to build the expander.
          <span {...row.getToggleRowExpandedProps()} title={calibrationTableLabels().expand_tips}>
            {row.isExpanded ?
            <svg className="icon mt-2 ms-2">
              <use xlinkHref={svgArrowFromBottom()}></use>
            </svg>
            :
            <svg className="icon mt-2 ms-2">
              <use xlinkHref={svgArrowFromTop()}></use>
            </svg>
            }
          </span>
        ),
        // We can override the cell renderer with a SubCell to be used with an expanded row
        SubCell: () => null // No expander on an expanded row
      },
      {
        Header: calibrationTableLabels().chinese_name,
        accessor: "chinese_name",
        Cell: ({ value: initialValue, row: { original} }) => <NameCell initialValue={initialValue} row_data={original} need_print={true} />,
      },
      {
        Header: calibrationTableLabels().title,
        accessor: "title",
        Cell: ({ value: initialValue }) =>  <p className="m-1">{initialValue}</p>,
      },
      {
        Header: calibrationTableLabels().department,
        accessor: "department",
        Cell: ({ value: initialValue }) =>  <p className="m-1">{initialValue}</p>,
      },
      ...original_calibration_table_header
      ]
    },
    []
  );

  const updateRawData = (rowIndex, columnId, value) => {
    setData(old =>
      old.map((row, index) => {
        if (index === rowIndex) {
          return {
            ...old[rowIndex],
            [columnId]: value,
          }
        }
        return row
      })
    )
  }

  // Set our editable cell renderer as the default Cell renderer
  const defaultColumn = {
    Cell: EditableCell,
  }

  const handleManagerOverallChange = (rowIndex, columnName, value) => {
  };

  // Create a function that will render our row sub components
  const renderRowSubComponent = React.useCallback(
    ({ row, rowProps, visibleColumns }) => (
      <OverallReview
        row={row}
        rowProps={rowProps}
        visibleColumns={visibleColumns}
        review_labels={calibrationTableLabels()}
        show_save_close_button={false}
        onManagerOverallChange={handleManagerOverallChange}
      />
    ),
    []
  );

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
    visibleColumns,
  } = useTable({ columns, data, defaultColumn, updateRawData, renderRowSubComponent, company_evaluation_templates, not_rated_text: calibrationTableLabels().not_rated}, useSortBy, useExpanded);

  const handleSave = (event) => {
    event.preventDefault();
    const submit_data = prepareTableSubmitData(data);
    put(currentPageJsonPath(group_level), {body: {calibration_table_session: submit_data}}).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          setData(result.need_calibration_eucs);
        });
      }
    });
  }

  const handleSaveAndSwitch = (event) => {
    event.preventDefault();
    const submit_data = prepareTableSubmitData(data);
    put(currentPageJsonPath(group_level), {body: {calibration_table_session: submit_data}}).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          window.location.href = result.calibration_sessions_path;
        });
      }
    });
  }

  function saveButon() {
    return <div className="row mt-2">
      <div className="col-2 text-end">
        <button onClick={handleSave} className="btn btn-primary">{calibrationTableLabels().save}</button>
      </div>
      <div className="col-4 mt-1">
        <span className="ms-3 text-info">{calibrationTableLabels().save_tips}</span>
      </div>
    </div>;
  }

  const show_save_button = false;

  return (
  <>
    {createPortal(
      <>
        <button onClick={handleSaveAndSwitch} className="nav-link" type="button" role="tab" aria-controls="nav-square"
                aria-selected="false">{calibrationTableLabels().nine_square_grid}</button>
        <button className="nav-link active" type="button" role="tab" aria-controls="nav-table"
                aria-selected="true">{calibrationTableLabels().table_grid}</button>
      </>,
      document.getElementById("switch-nav")
    )}
    <table {...getTableProps()} className="table table-striped table-bordered">
      <thead>
      {headerGroups.map(headerGroup => (
        <tr {...headerGroup.getHeaderGroupProps()}>
          {headerGroup.headers.map(column => (
            <th {...column.getHeaderProps(column.getSortByToggleProps())}>
              {column.render('Header')}
              {/* Add a sort direction indicator */}
              <span>
                  {column.isSorted
                    ? column.isSortedDesc
                      ? ' 🔽'
                      : ' 🔼'
                    : ''}
                </span>
            </th>
          ))}
        </tr>
      ))}
      </thead>
      <tbody {...getTableBodyProps()}>
      {rows.map(row => {
        prepareRow(row);
        const rowProps = row.getRowProps();
        return (
          // Use a React.Fragment here so the table markup is still valid
          <React.Fragment key={rowProps.key}>
            <tr {...row.getRowProps()}>
              {row.cells.map(cell => {
                return (
                  <td {...cell.getCellProps()} className="p-1">
                    {cell.column.id === 'rowNumber' ? cell.render('Cell', { rows }) : cell.render('Cell')}
                  </td>
                )
              })}
            </tr>
            {row.isExpanded &&
              renderRowSubComponent({row, rowProps, visibleColumns})}
          </React.Fragment>
        )
      })}
      </tbody>
    </table>
    {show_save_button && saveButon()}
  </>
  );
}

export default CalibratioTable;
