import * as React from 'react';
import { createPortal } from 'react-dom';
import {flexRender, getCoreRowModel, getSortedRowModel, useReactTable} from '@tanstack/react-table'
import {get, put} from '@rails/request.js'
import {markScoresTableHeader, reviewLabels, svgArrowFromTop, svgArrowFromBottom, prepareTableSubmitData} from "./utils/tableHeader";
import {currentPageJsonPath} from "./utils/url";
import {EditableCell} from "./table/EditableCell";
import {NameCell} from "./table/NameCell";
import {PopoversHeader} from "./table/PopoversHeader";
import {OverallReview} from "./table/OverallReview";
import {MarkScoreConfirmDialog} from "./modal_dialog/MarkScoreConfirmDialog";

// Custom hook for fetching data
function useFetchData(group_level, mark_score_group, setUpdatedData) {
  const [company_evaluation_templates, setCompanyEvaluationTemplates] = React.useState({});
  const [raw_data, setData] = React.useState([]);
  const [expanded, setExpanded] = React.useState([]);

  React.useEffect(() => {
    get(currentPageJsonPath(group_level, mark_score_group)).then((response) => {
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
function useSave(group_level, mark_score_group, updatedData, setData, setUpdatedData) {
  const [firstSaved, setFirstSaved] = React.useState(false);
  const [successSaveMessage, setSuccessSaveMessage] = React.useState("");
  const [confirmMessage, setConfirmMessage] = React.useState({accepted: false, message: ""});

  const handleSave = (event, confirm = false) => {
    event.preventDefault();
    const submit_data = prepareTableSubmitData(updatedData);
    put(currentPageJsonPath(group_level, mark_score_group), {body: {confirm, mark_score: submit_data}}).then((response) => {
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

function MarkScores({group_level, mark_score_group = null, table_header = null}) {
  const [updatedData, setUpdatedData] = React.useState([]);
  const { company_evaluation_templates, raw_data, expanded, setData, setExpanded } = useFetchData(group_level, mark_score_group, setUpdatedData);
  const { firstSaved, successSaveMessage, confirmMessage, setFirstSaved, setSuccessSaveMessage, handleSave, handleClose } = useSave(group_level, mark_score_group, updatedData, setData, setUpdatedData);

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
      const original_mark_scores_table_header = markScoresTableHeader(group_level, table_header);
      const extended_mark_scores_table_header = original_mark_scores_table_header.map(column => ({
        accessorKey: column.accessor,
        header: () => <PopoversHeader header={column.Header} accessor={column.accessor} description={column.description} />,
        sortingFn: (rowA, rowB, columnId) => {
          const valueColumnId = columnId === "raw_total_evaluation_score_raw" ? "raw_total_evaluation_score" : columnId;
          const a = parseFloat(rowA.getValue(valueColumnId));
          const b = parseFloat(rowB.getValue(valueColumnId));

          if (isNaN(a) || isNaN(b)) {
            return String(rowA.getValue(valueColumnId)).localeCompare(String(rowB.getValue(valueColumnId)));
          }

          return a - b;
        }
      }));

      return [
      {
        header: reviewLabels().row_number,
        id: 'rowNumber',
        cell: ({ row, table }) => {
          const sortedRowIndex = table.getRowModel().rows.findIndex(sortedRow => sortedRow.id === row.id);
          return <div className="m-1 text-end">{sortedRowIndex + 1}</div>;
        },
      },
      {
        // Make an expander cell
        header: () => reviewLabels().comment,
        id: 'expander', // It needs an ID if no accessor
        cell: ({ row }) => (
          <span
            onClick={() => setExpandedByRowIndex(row.index)}
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
        )
      },    
      {
        header: reviewLabels().chinese_name,
        accessorKey: "chinese_name",
        cell: ({ getValue, row: { original} }) => <NameCell initialValue={getValue()} row_data={original} need_print={false} />,
      },
      {
        header: reviewLabels().title,
        accessorKey: "title",
        cell: ({ getValue }) =>  <p className="m-1">{getValue()}</p>,
      },
      {
        header: reviewLabels().department,
        accessorKey: "department",
        cell: ({ getValue }) =>  <p className="m-1">{getValue()}</p>,
      },
      ...extended_mark_scores_table_header
      ]
    },
    [expanded, table_header]
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
    cell: EditableCell,
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

  const table = useReactTable({
    columns,
    data,
    defaultColumn,
    meta: {
      updateRawData,
      setFirstSaved,
      company_evaluation_templates,
      not_rated_text: reviewLabels().not_rated
    },
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    sortDescFirst: false
  });

  const visibleColumns = table.getVisibleLeafColumns();

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
