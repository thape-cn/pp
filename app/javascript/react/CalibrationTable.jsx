import * as React from 'react';
import { createPortal } from 'react-dom';
import {flexRender, getCoreRowModel, getExpandedRowModel, getSortedRowModel, useReactTable} from '@tanstack/react-table'
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
      const original_calibration_table_header = calibrationTableHeader().map(column => ({
        accessorKey: column.accessor,
        header: column.Header
      }));
      return [
      {
        header: calibrationTableLabels().row_number,
        id: 'rowNumber',
        cell: ({ row, table }) => {
          const sortedRowIndex = table.getRowModel().rows.findIndex(sortedRow => sortedRow.id === row.id);
          return <div className="m-1 text-end">{sortedRowIndex + 1}</div>;
        },
      },
      {
        // Make an expander cell
        header: () => "评论", // No header
        id: 'expander', // It needs an ID if no accessor
        cell: ({ row }) => (
          <span onClick={row.getToggleExpandedHandler()} title={calibrationTableLabels().expand_tips}>
            {row.getIsExpanded() ?
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
      },
      {
        header: calibrationTableLabels().chinese_name,
        accessorKey: "chinese_name",
        cell: ({ getValue, row: { original} }) => <NameCell initialValue={getValue()} row_data={original} need_print={true} />,
      },
      {
        header: calibrationTableLabels().title,
        accessorKey: "title",
        cell: ({ getValue }) =>  <p className="m-1">{getValue()}</p>,
      },
      {
        header: calibrationTableLabels().department,
        accessorKey: "department",
        cell: ({ getValue }) =>  <p className="m-1">{getValue()}</p>,
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
    cell: EditableCell,
  }

  const handleManagerOverallChange = (rowIndex, columnName, value) => {
  };

  // Create a function that will render our row sub components
  const renderRowSubComponent = React.useCallback(
    ({ row, visibleColumns }) => (
      <OverallReview
        row={row}
        visibleColumns={visibleColumns}
        review_labels={calibrationTableLabels()}
        show_save_close_button={false}
        onManagerOverallChange={handleManagerOverallChange}
      />
    ),
    []
  );

  const table = useReactTable({
    columns,
    data,
    defaultColumn,
    meta: {
      updateRawData,
      setFirstSaved: () => {},
      company_evaluation_templates,
      not_rated_text: calibrationTableLabels().not_rated
    },
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getExpandedRowModel: getExpandedRowModel(),
    getRowCanExpand: () => true,
    sortDescFirst: false
  });

  const visibleColumns = table.getVisibleLeafColumns();

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
    <table className="table table-striped table-bordered">
      <thead>
      {table.getHeaderGroups().map(headerGroup => (
        <tr key={headerGroup.id}>
          {headerGroup.headers.map(header => (
            <th
              key={header.id}
              colSpan={header.colSpan}
              scope="col"
              aria-sort={header.column.getIsSorted() === 'asc' ? 'ascending' : header.column.getIsSorted() === 'desc' ? 'descending' : undefined}
              onClick={header.column.getToggleSortingHandler()}
            >
              {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
              {/* Add a sort direction indicator */}
              <span>
                  {header.column.getIsSorted()
                    ? header.column.getIsSorted() === 'desc'
                      ? ' 🔽'
                      : ' 🔼'
                    : ''}
                </span>
            </th>
          ))}
        </tr>
      ))}
      </thead>
      <tbody>
      {table.getRowModel().rows.map(row => {
        return (
          // Use a React.Fragment here so the table markup is still valid
          <React.Fragment key={row.id}>
            <tr>
              {row.getVisibleCells().map(cell => {
                return (
                  <td key={cell.id} className="p-1">
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                )
              })}
            </tr>
            {row.getIsExpanded() &&
              renderRowSubComponent({row, visibleColumns})}
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
