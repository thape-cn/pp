import * as React from 'react';
import { createPortal } from 'react-dom';
import {useSortBy, useExpanded, useTable} from 'react-table'
import {get, put} from '@rails/request.js'
import {markScoresTableHeader, reviewLabels, svgArrowFromTop, svgArrowFromBottom, prepareTableSubmitData} from "./utils/tableHeader";
import {currentPageJsonPath} from "./utils/url";
import {EditableCell} from "./table/EditableCell";
import {NameCell} from "./table/NameCell";
import {PopoversHeader} from "./table/PopoversHeader";
import {OverallReview} from "./table/OverallReview";
import {MarkScoreConfirmDialog} from "./modal_dialog/MarkScoreConfirmDialog";

// Custom hook for fetching data
function useFetchData(group_level, setUpdatedData) {
  const [company_evaluation_templates, setCompanyEvaluationTemplates] = React.useState({});
  const [raw_data, setData] = React.useState([]);
  const [expanded, setExpanded] = React.useState([]);

  React.useEffect(() => {
    get(currentPageJsonPath(group_level)).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          setCompanyEvaluationTemplates(result.company_evaluation_templates);
          setData(result.need_review_evaluations);
          setUpdatedData(result.need_review_evaluations);
          const initialExpandedState = Array(result.need_review_evaluations.length).fill(false);
          setExpanded(initialExpandedState);
        });
      }
    });
  }, []);

  return { company_evaluation_templates, raw_data, expanded, setData, setExpanded };
}

// Custom hook for handling save and save & confirm
function useSave(group_level, updatedData, setData, setUpdatedData) {
  const [firstSaved, setFirstSaved] = React.useState(false);
  const [successSaveMessage, setSuccessSaveMessage] = React.useState("");
  const [confirmMessage, setConfirmMessage] = React.useState({accepted: false, message: ""});

  const handleSave = (event, confirm = false) => {
    event.preventDefault();
    const submit_data = prepareTableSubmitData(updatedData);
    put(currentPageJsonPath(group_level), {body: {confirm, mark_score: submit_data}}).then((response) => {
      if (response.ok) {
        const result_json = response.json;
        result_json.then(result => {
          if (confirm) {
            setConfirmMessage((currentConfrimMessage) => {
              return {accepted: result.accepted, message: result.message}
            });
          } else {
            setFirstSaved(true);
            setSuccessSaveMessage(result.message);
          }
          setData(result.need_review_evaluations);          
          setUpdatedData(result.need_review_evaluations);
        });
      }
    });
  }

  const handleClose = () => {
    setConfirmMessage((currentConfirmMessage) => {
      return {accepted: currentConfirmMessage.accepted, message: ""}
    });
  }

  return { firstSaved, successSaveMessage, confirmMessage, setFirstSaved, setSuccessSaveMessage, handleSave, handleClose };
}

function MarkScores({group_level}) {
  const [updatedData, setUpdatedData] = React.useState([]);
  const { company_evaluation_templates, raw_data, expanded, setData, setExpanded } = useFetchData(group_level, setUpdatedData);
  const { firstSaved, successSaveMessage, confirmMessage, setFirstSaved, setSuccessSaveMessage, handleSave, handleClose } = useSave(group_level, updatedData, setData, setUpdatedData);

  const data = React.useMemo(
    () => raw_data,
    [raw_data]
  );

  const setExpandedByRowIndex = (rowIndex) => {
    setExpanded((currentExpanded) => {
      const newExpanded = [...currentExpanded];
      newExpanded[rowIndex] = !currentExpanded[rowIndex];
      return newExpanded;
    });
  }

  const columns = React.useMemo(
    () => {
      const original_mark_scores_table_header = markScoresTableHeader(group_level);
      const extended_mark_scores_table_header = original_mark_scores_table_header.map(column => ({
        ...column,
        Header: () => <PopoversHeader header={column.Header} accessor={column.accessor} description={column.description} />,
        sortType: (rowA, rowB, columnId) => {
          if ("raw_total_evaluation_score_raw" == columnId)
            columnId = "raw_total_evaluation_score"
          const a = parseFloat(rowA.values[columnId]);
          const b = parseFloat(rowB.values[columnId]);

          if (isNaN(a) || isNaN(b)) {
            return String(rowA.values[columnId]).localeCompare(String(rowB.values[columnId]));
          }

          return a - b;
        }
      }));

      return [
      {
        Header: reviewLabels().row_number,
        id: 'rowNumber',
        Cell: ({ row, rows }) => {
          const sortedRowIndex = rows.findIndex(sortedRow => sortedRow.id === row.id);
          return <div className="m-1 text-end">{sortedRowIndex + 1}</div>;
        },
      },
      {
        // Make an expander cell
        Header: () => reviewLabels().comment,
        id: 'expander', // It needs an ID if no accessor
        Cell: ({ row }) => (
          <span
            {...row.getToggleRowExpandedProps({
              onClick: () => setExpandedByRowIndex(row.index)
            })}
            title={reviewLabels().expand_tips}
          >
            {expanded[row.index] ?
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
        Header: reviewLabels().chinese_name,
        accessor: "chinese_name",
        Cell: ({ value: initialValue, row: { original} }) => <NameCell initialValue={initialValue} row_data={original} need_print={false} />,
      },
      {
        Header: reviewLabels().title,
        accessor: "title",
        Cell: ({ value: initialValue }) =>  <p className="m-1">{initialValue}</p>,
      },
      {
        Header: reviewLabels().department,
        accessor: "department",
        Cell: ({ value: initialValue }) =>  <p className="m-1">{initialValue}</p>,
      },
      ...extended_mark_scores_table_header
      ]
    },
    [expanded]
  );

  const updateRawData = (rowIndex, columnId, value) => {
    setUpdatedData(old =>
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
    setUpdatedData(old =>
      old.map((row, index) => {
        if (index === rowIndex) {
          return {
            ...old[rowIndex],
            [columnName]: value,
          }
        }
        return row
      })
    )
  };

  // Create a function that will render our row sub components
  const renderRowSubComponent = React.useCallback(
    ({ row, visibleColumns }) => (
      <OverallReview
        row={row}
        visibleColumns={visibleColumns}
        review_labels={reviewLabels()}
        show_save_close_button={true}
        setExpandedByRowIndex={setExpandedByRowIndex}
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
    state: { sortBy }, // Destructure sortBy from state
  } = useTable(
    {
      columns, data, defaultColumn, updateRawData, setFirstSaved, renderRowSubComponent,
      company_evaluation_templates, not_rated_text:  reviewLabels().not_rated,
      autoResetExpanded: false, // This prevents the expanded state from resetting when data changes
      autoResetSortBy: false,   // This prevents the sorting state from resetting when data changes
      expanded
    },
    useSortBy, useExpanded
  );

  // Create a new state for sorted columns
  const [sortedColumns, setSortedColumns] = React.useState(sortBy);

  // Update sortedColumns state when sortBy changes
  React.useEffect(() => {
    setSortedColumns(sortBy);
  }, [sortBy]);

  function submitDataEucsIds() {
    return data.map(function (obj) {
      return obj["id_euc"];
    });
  }

  const handleSaveAndConfirm = (event) => {
    handleSave(event, true);
  }

  return (
  <>
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
              {expanded[row.index] &&
                renderRowSubComponent({ row, visibleColumns })}
            </React.Fragment>              
          )
        })}
      </tbody>
    </table>
    {(data && data.length != 0) ?
    <div className="row mt-2">
      <div className="col-2 text-end">
        <button onClick={handleSave} className="btn btn-primary">{reviewLabels().save}</button>
      </div>
      <div className="col-6">
        <button onClick={handleSaveAndConfirm} className="btn btn-warning" disabled={!firstSaved}>
          {reviewLabels().save_and_confirm}
        </button>
        <span className="ms-3 text-info">{reviewLabels().save_and_confirm_tips}</span>
      </div>
    </div> : null}
    {successSaveMessage && createPortal(
      <div className="mb-0 alert alert-primary alert-dismissible fade show" role="alert">
        {successSaveMessage}
        <button onClick={() => setSuccessSaveMessage("")} aria-label="Close" className="btn-close" type="button"></button>
      </div>,
      document.getElementById("flash-root")
    )}
    {confirmMessage.message && createPortal(
      <MarkScoreConfirmDialog
        accepted={confirmMessage.accepted}
        euc_ids={submitDataEucsIds()}
        message={confirmMessage.message}
        onClose={handleClose}
      />,
      document.getElementById("coreuiModal")
    )}
  </>
  );
}

export default MarkScores;
