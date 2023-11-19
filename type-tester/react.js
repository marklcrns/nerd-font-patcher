import React from 'react';

// MUI components
import { Box } from '@mui/material/';
import MUIDataTable from 'mui-datatables';

// Local components
import ViewService from '../../components/database-management/ViewService.js';

// Utils
import { useNavigate } from 'react-router-dom';

// ----------------------------------------------------------------------

// Service config overrides
const config = {};

// ----------------------------------------------------------------------

const ViewDepartment = () => {
  const navigate = useNavigate();

  const handleOnRowClick = (event) => {
    const nodeID = event[0].toString();
    navigate(nodeID, { replace: false });
  };

  const setOptions = (context) => {
    return {
      filterType: 'multiselect',
      fixedHeader: true,
      selectableRows: 'none',
      elevation: 10,
      tableBodyMaxHeight: '500px',
      onRowClick: handleOnRowClick,
      setTableProps: () => {
        return {
          size: 'small'
        };
      }
    };
  };

  return (
    <>
      <ViewService service='department' config={config}>
        {({ context, data, tableColumns }) => (
          <Box px={3} py={2}>
            <MUIDataTable
              title='Department Table'
              data={data}
              columns={tableColumns}
              options={setOptions(context)}
            />
          </Box>
        )}
      </ViewService>
    </>
  );
};

export default ViewDepartment;
